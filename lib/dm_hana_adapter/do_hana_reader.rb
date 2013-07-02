require 'data_objects'

module DataObjects
  module Hana
    
      class Reader < DataObjects::Reader
        def initialize( command, handle)
          @command, @handle = command, handle
          return unless @handle

          @fields = handle.columns
	        DataObjects::Hana.logger.debug("#{command.inspect} and handle is #{handle.inspect}")
          @rows = []
          types = @command.types
          if types && types.size != @fields.size
            close
            raise ArgumentError, "Field-count mismatch. Expected #{types.size} fields, but the query yielded #{@fields.size}"
          end
          DataObjects::Hana.logger.debug("About to fetch rows")
          # Do NOT use @handle.each as it causes a segfault
          while row = @handle.fetch
	          DataObjects::Hana.logger.debug("Row #{row.inspect}")
            field = -1
            @rows << row.map do |value|
              field += 1
	      
              next value unless types
	            t = types[field]
	      
	            DataObjects::Hana.logger.debug("Type #{t.inspect} value #{value.inspect}")
	      
	            unless value.nil?
  	            begin
      		        if t == Integer
      		          value.to_i
      		        elsif t == Float
      		          value.to_f
      		        elsif t == String
      		          value.to_s
      		        elsif t == Date
      		          ODBC.to_date(value.to_s)
      		        elsif t == Time
      		          Time.new(value.to_s)
      		          #ODBC.to_time(value) # For some reason, ODBC.to_time always barfed
      		        elsif t == DateTime
      		          ODBC.to_date(value.to_s)
      		        elsif t == TrueClass
      		          if value == 0
      		            false
      		          else
      		            true
      		          end
      		        else
      		          t.new(value)
      		        end
      		      rescue e
		              DataObjects::Hana.logger.error "OOPS! #{e.stacktrace}"
		            end
	            end
            end
          end
	        DataObjects::Hana.logger.debug("Closing statement")
          close
          @current_row = -1
        end

        def close
          if @handle
	          DataObjects::Hana.logger.debug("About to call drop on handle #{@handle}")
            @handle.drop if  @handle.respond_to?(:drop)
            @handle = nil
            true
          else
            false
          end
        end

        def next!
          (@current_row += 1) < @rows.size
        end

        def values
          raise StandardError.new("First row has not been fetched") if @current_row < 0
          raise StandardError.new("Last row has been processed") if @current_row >= @rows.size
          @rows[@current_row]
        end

        def fields
          @fields
        end

        def field_count
          @fields.size
        end

        # REVISIT: This is being deprecated
        def row_count
          @rows.size
        end
      end
  end
end