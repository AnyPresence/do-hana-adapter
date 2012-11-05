require 'dm-core'
require 'dm-do-adapter'
require 'dm_hana_adapter/dm_do_hana_migrations'
require 'dm_hana_adapter/do_hana_connection'
require 'dm_hana_adapter/do_hana_quoting'
require 'odbc_utf8'

module DataMapper
  module Adapters
    
    class HanaAdapter < DataMapper::Adapters::DataObjectsAdapter
      
      SQL_FALSE = '1 = 0'.freeze
            
      include DataMapper::Migrations::HanaAdapter
      include DataObjects::Quoting
      
      def initialize(name, uri_or_options)
        super(name,uri_or_options)
	
        @host = uri_or_options[:host]
        raise "No host provided!" if @host.nil?
	@port = uri_or_options[:port]
        @username = uri_or_options[:username]
        @password = uri_or_options[:password]
        @schema = uri_or_options[:schema]
      end
      
      def schema_name
        @schema
      end
      
      # @api private
      def supports_default_values?
        false
      end
  
      # @api semipublic
      def create(resources)
        DataObjects::Hana.logger.debug("create(\n#{resources.inspect}\n)")
        name = self.name

        resources.each do |resource|
          model = resource.model
          serial = model.serial(name)
          attributes = resource.dirty_attributes
	  
          properties = []
          bind_values = []

          # make the order of the properties consistent
          model.properties(name).each do |property|
            next unless attributes.key?(property)

            bind_value = attributes[property]
	    
	    if property.default?
	      raise "PROPERTY #{property.inspect} is default and its bind value is #{bind_value.inspect}"
	    end
	    
            # skip inserting NULL for columns that are serial or without a default
            next if bind_value.nil? && (property.serial? || !property.default?)

            # if serial is being set explicitly, do not set it again
            if property.equal?(serial)
              serial = nil
            end

            properties << property
            bind_values << quote_value(bind_value)
          end
	  
	  serial_id = nil
	  
	  if serial
	    
	    serial_id = select(next_sequence_value_statement(model)).first
	    DataObjects::Hana.logger.debug("Serial id is #{serial_id.inspect}")
	    
	    properties << serial
	    bind_values << serial_id
	  end
	  
          statement = insert_statement(model, properties, serial)
	  DataObjects::Hana.logger.debug("Firing off insert statement of #{statement.inspect}")
	  
          result = with_connection do |connection|
            connection.create_command(statement).execute_non_query(*bind_values)
          end

          if result.affected_rows == 1 && serial
	    DataObjects::Hana.logger.debug("Setting serial on #{serial.inspect} to #{serial_id.inspect}")
            serial.set!(resource, serial_id)
          end
        end
      end
      
      
      # @api private
      def next_sequence_value_statement(model)
	# Do not change this to what it probably should be, which is the table backing model, otherwise no value is returned if table has no records. Fun!
	"SELECT #{quote_name(sequence_name(model))}.nextval FROM DUMMY" 
      end
	
      # Constructs comparison clause
        #
        # @return [String]
        # comparison clause
        #
        # @api private
        def comparison_statement(comparison, qualify)
          subject = comparison.subject
          value = comparison.value

          # TODO: move exclusive Range handling into another method, and
          # update conditions_statement to use it

          # break exclusive Range queries up into two comparisons ANDed together
          if value.kind_of?(Range) && value.exclude_end?
            operation = Query::Conditions::Operation.new(:and,
              Query::Conditions::Comparison.new(:gte, subject, value.first),
              Query::Conditions::Comparison.new(:lt, subject, value.last)
            )

            statement, bind_values = conditions_statement(operation, qualify)

            return "(#{statement})", bind_values
          elsif comparison.relationship?
            if value.respond_to?(:query) && value.respond_to?(:loaded?) && !value.loaded?
              return subquery(value.query, subject, qualify)
            else
              return conditions_statement(comparison.foreign_key_mapping, qualify)
            end
          elsif comparison.slug == :in
            nil_values, other_values = value.partition { |entry| entry.nil? }

            if nil_values.empty? and other_values.empty?
              # The "in" clause is an empty list. This can be evaluated two
              # ways:
              #
              # * when not negated, it means: match nothing
              # * when negated, it means: match everything
              #
              # These semantics can be explained with the following ruby examples:
              #
              # * [].include?(any_value) # => false
              # * ! [].include?(any_value) # => true
              #
              # In two-valued logic the statement "does the value match an
              # empty set" is always false. Conversely the statement "does the
              # value not match an empty set" is always true.
              #
              # This returns an SQL statement that is always false, and it may
              # be negated by an outer negation operator in the case where we
              # are looking for "a value not in an empty set".
              return SQL_FALSE, []
            elsif nil_values.empty?
              # the "in" clause contains non-nil values, so the normal code path
              # can handle this condition.
            else
              # the "in" clause contains a nil value, so create a query that
              # handles mixed nil and non-nil values.
              disjunction = Query::Conditions::Operation.new(:or,
                Query::Conditions::Comparison.new(:in, subject, other_values),
                Query::Conditions::Comparison.new(:eql, subject, nil)
              )

              return conditions_statement(disjunction, qualify)
            end
          end

          operator = comparison_operator(comparison)
          column_name = property_to_column_name(subject, qualify)

          # if operator return value contains ? then it means that it is function call
          # and it contains placeholder (%s) for property name as well (used in Oracle adapter for regexp operator)
          if operator.include?('?')
            return operator % column_name, [ value ]
          else
	    
	    if operator == 'BETWEEN' && value.kind_of?(Range)
	      return "#{column_name} BETWEEN ? AND ?", [ value.to_a.first, value.to_a.last ].compact #Ruby ODBC can't handle ranges
	    end
	    
	    if operator == 'IN' && value.kind_of?(Array)
	      return "#{column_name} IN (#{(['?'] * value.size).join(', ')})", [ *value ].compact
	    end
	    
	    return "#{column_name} #{operator} #{value.nil? ? 'NULL' : '?'}", [ value ].compact
	    
            
          end
        end
  

      module SQL
	# HANA's maximum allowed identifier length
	IDENTIFIER_MAX_LENGTH = 127 
 
        # @api private
        def supports_default_values? #:nodoc:
          false
        end
	
      end
     
      
    end #class HanaAdapter
    
    
    const_added(:HanaAdapter)
    
  end
end
