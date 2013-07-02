require 'data_objects'
require 'dm_hana_adapter/do_hana_reader'

module DataObjects
  module Hana
    
    class Command < DataObjects::Command

          attr_reader :types
	  
          def set_types(*t)
            @types = t.flatten
          end
	  
          def execute_non_query(*args)
            DataObjects::Hana.check_params(@text, args)
	    
	          row_count = nil
	          inserted_id = nil
	          DataObjects::Hana.logger.debug("Query: #{@text} \nArgs: #{args.inspect}")
            begin
	            row_count = @connection.execute(@text,*args)
            rescue ODBC::Error => e
              DataObjects::Hana.raise_db_error(e, @text, args)
            end

            Result.new(self, row_count, inserted_id)
          end

          def execute_reader( *args)
            DataObjects::Hana.check_params( @text, args)
            massage_limit_and_offset args
	    
	          DataObjects::Hana.logger.debug("Query: #{@text} \nArgs: #{args.inspect}")
            begin
              statement = @connection.prepare_statement(@text)
              handle = statement.execute(*args)
            rescue ODBC::Error => e
              DataObjects::Hana.raise_db_error(e, @text, args)
            rescue
              raise
            end
	    
            ::DataObjects::Hana::Reader.new(self, handle)
          end
      
        private
          def massage_limit_and_offset( args)
	    
            @text.sub!(%r{SELECT (.*) ORDER BY (.*) LIMIT ([?0-9]*)( OFFSET ([?0-9]*))?}) {
              what, order, limit, offset = $1, $2, $3, $5

              # LIMIT and OFFSET will probably be set by args. We need exact values, so must
              # do substitution here, and remove those args from the array. This is made easier
              # because LIMIT and OFFSET are always the last args in the array.
              offset = args.pop if offset == '?'
              limit = args.pop if limit == '?'
              offset = offset.to_i
              limit = limit.to_i

              # Reverse the sort direction of each field in the ORDER BY:
              rev_order = order.split(/, */).map{ |f|
                f =~ /(.*) DESC *$/ ? $1 : f+" DESC"
              }*", "

              "SELECT TOP #{limit} * FROM (SELECT TOP #{offset+limit} #{what} ORDER BY #{rev_order}) ORDER BY #{order}"
            }
	    
          end
    end
    
    private
    
    def self.check_params( cmd, args)
      actual = args.size
      expected = param_count(cmd)
      raise ArgumentError.new("Binding mismatch: #{actual} for #{expected}") if actual != expected
    end

    def self.raise_db_error(e, cmd, args)
      msg = e.inspect
      case msg
      when /Too much parameters/, /No data found/
	  DataObjects::Hana.logger.debug("'#{cmd}' (#{args.map{|a| a.inspect}*", "}): #{e.backtrace}")
          check_params(cmd, args)
      else
          DataObjects::Hana.logger.debug("'#{cmd}' (#{args.map{|a| a.inspect}*", "}): #{e.backtrace}")
      end
      #DataObjects::Hana.logger.debug( e.backtrace)
      raise
    end

    def self.param_count cmd
      cmd.gsub(/'[^']*'/,'').scan(/\?/).size
    end
    
  end
end
