require 'dm-migrations'

module DataMapper
  module Migrations
    module HanaAdapter

      HANA_FAKE_SERIAL_SEQUENCE_NAME_PREFIX = 'seq_'
      DEFAULT_CHARACTER_SET = 'utf8'.freeze
      
      # Magic numbers! See http://help.sap.com/hana/html/_csql_data_types.html#sql_data_types_introduction_numeric
      TINY_INT_MIN  = 0
      TINY_INT_MAX  = 255
      SMALL_INT_MIN = -32768
      SMALL_INT_MAX =  32767
      INTEGER_MIN   = -2147483648
      INTEGER_MAX   =  2147483647
      BIG_INT_MIN   = -9223372036854775808
      BIG_INT_MAX   =  9223372036854775807
      
      include DataObjectsAdapter

      # @api private
      def self.included(base)
        base.extend DataObjectsAdapter::ClassMethods
        base.extend ClassMethods
      end
      
      # @api semipublic
      def storage_exists?(storage_name)
        select("SELECT TABLE_NAME FROM TABLES WHERE TABLE_NAME LIKE ?", storage_name).first == storage_name
      end

      # @api semipublic
      def field_exists?(storage_name, field_name)
        result = select("SELECT COLUMN_NAME FROM TABLE_COLUMNS WHERE TABLE_NAME = ? AND COLUMN_NAME LIKE ?", storage_name, field_name).first
        result ? result.to_s == field_name.to_s : false
      end

      def sequence_exists?(sequence_name)
	select("SELECT SEQUENCE_NAME FROM SEQUENCES WHERE SEQUENCE_NAME LIKE ?",sequence_name).first == sequence_name
      end

      def sequence_name(model)
	HANA_FAKE_SERIAL_SEQUENCE_NAME_PREFIX + model.storage_name(self.name)
      end
      
      # @api semipublic
      def create_model_storage(model)
	
	# Create a sequence that we can use for serials
	unless sequence_exists?(sequence_name(model))
	  with_connection do |connection|
	    statement = create_sequence_statement(model)
	    command = connection.create_command(statement)
	    command.execute_non_query
	  end
	end
	
	super model
      end
      
      module SQL #:nodoc:
#        private  ## This cannot be private for current migrations

        
	# @api private
        def schema_name
          @options[:schema]
        end

        alias_method :db_name, :schema_name # Need these still?

	# @api private
	def create_sequence_statement(model)
	    
	    statement = "CREATE SEQUENCE "
	    
	    storage_name = sequence_name(model) 
	    
	    statement << quote_name(storage_name)
	    
	    statement
	end
	
        # @api private
        def alter_table_add_column_statement(connection, table_name, schema_hash)
          "ALTER TABLE #{quote_name(table_name)} #{add_column_statement} ( #{property_schema_statement(connection, schema_hash)} )"
        end

        # @api private
        def add_column_statement
          'ADD '
        end

        # @api private
        def create_table_statement(connection, model, properties)
	  statement_pieces = []
	  
	  create_statement = "CREATE TABLE #{quote_name(model.storage_name(name))} ("
	  
	  sql_columns = []
	  
	  properties.map do |property|
	    sql = property_schema_statement(connection, property_schema_hash(property))
	    if property.serial?
	      sql << " PRIMARY KEY "
	    end
	    sql_columns << sql
	  end
	  
	  create_statement << sql_columns.join(',')
	  
	  create_statement << ')'
	  
	  ::DataMapper::Ext::String.compress_lines(create_statement)
	 
        end

        # @api private
        def property_schema_hash(property)
          schema = super
	  #puts "property_schema_hash called with property #{property.inspect} and schema is #{schema.inspect}"
	  
          if property.kind_of?(Property::Integer)
            min = property.min
            max = property.max

            schema[:primitive] = integer_column_statement(min..max) if min && max
          end
	  
          if schema[:primitive] == 'TEXT'
            schema.delete(:default)
          end
	  
          schema
        end

        # @api private
        def property_schema_statement(connection, schema)
          #puts "property_schema_statement called with connection #{connection.inspect} and schema is #{schema.inspect}"
	  
	  if supports_serial? &&  schema[:serial]
            statement = quote_name(schema[:name])
            statement << " #{schema[:primitive]}"

            length = schema[:length]

            if schema[:precision] && schema[:scale]
              statement << "(#{[ :precision, :scale ].map { |key| connection.quote_value(schema[key]) }.join(', ')})"
            elsif length
              statement << "(#{connection.quote_value(length)})"
            end

          else
            statement = super
          end
	  
          statement
        end

        # @api private
        def character_set
          @character_set ||= show_variable('character_set_connection') || DEFAULT_CHARACTER_SET
        end

        # @api private
        def collation
          @collation ||= show_variable('collation_connection') || DEFAULT_COLLATION
        end

        # @api private
        def show_variable(name)
          raise "hanaAdapter#show_variable: Not implemented"
        end

        private

        # Return SQL statement for the integer column
        #
        # @param [Range] range
        #   the min/max allowed integers
        #
        # @return [String]
        #   the statement to create the integer column
        #
        # @api private
        def integer_column_statement(range)
          min = range.first
          max = range.last

          if    min >= TINY_INT_MIN         && max < TINY_INT_MAX     then 'TINYINT'
          elsif min >= SMALL_INT_MIN && max < SMALL_INT_MAX then 'SMALLINT'
          elsif min >= INTEGER_MIN  && max < INTEGER_MAX  then 'INTEGER'
          elsif min >= BIG_INT_MIN   && max < BIG_INT_MAX   then 'BIGINT'
          else
            raise ArgumentError, "min #{min} and max #{max} exceeds supported range"
          end
        end

      end # module SQL

      include SQL

      module ClassMethods
        # Types for SAP HANA databases.
        #
        # @return [Hash] types for HANA databases.
        #
        # @api private
        def type_map
          length    = Property::String.length
          precision = Property::Numeric.precision
          scale     = Property::Decimal.scale
	  max       = 5000 #Property::Text.length
          
          super.merge(
            DateTime       => { :primitive => 'TIMESTAMP'                 },
            Date           => { :primitive => 'DATE'                      },
            Time           => { :primitive => 'TIME'                      },
            TrueClass      => { :primitive => 'TINYINT'                   },
            Property::Text => { :primitive => 'NVARCHAR', :length => max  } 
          ).freeze
        end
  
      end

    end
  end
end
