require 'data_objects'

module DataObjects
  module Hana
    
    class Connection < DataObjects::Connection
      
      self.class_eval do
	      def quote_boolean(value)
	        value ? 1 : 0
	      end
      end

  
      def initialize(uri)
        @host = uri.query && uri.query["host"]

        raise "No host provided in parameters!" unless @host
	
	      @port = uri.query && uri.query["port"] 
	
	      if @port
	        @host = "#{@host}:#{@port}"
	      end
	      
	      username = uri.query && uri.query["username"]
	      password = uri.query && uri.query["password"]
	
	      DataObjects::Hana.logger.debug("Connecting to #{@host} as #{username}")
	      begin
          @connection = ODBC::Database.new(@host,username,password)
          @connection.use_utc = true
	        @connection.use_time = true
	        @connection.ignorecase = true
        rescue ODBC::Error => e
          raise e
        end
        
        @encoding = uri.query && uri.query["encoding"] || "utf8"
      end

      def character_set
        @encoding
      end

      def close
        begin
          if @connection.connected?
            @connection.drop_all #This is NOT a drop, it simply releases all open Statement objects.
            @connection.disconnect
          else
            true
          end
        rescue => e
          DataObjects::Hana.logger.error("Error while closing connection: #{e}")
          false
        end
      end
      
      def new_statement
        raise "Defective"
        @connection.newstmt
      end
      
      def prepare_statement(sql)
        @connection.prepare(sql)
      end
      
      def execute(sql,*args)
	      DataObjects::Hana.logger.debug("\nExecute(#{sql.inspect},#{args.inspect}")
	      ret = @connection.do(sql,*args)
	      DataObjects::Hana.logger.debug("Execute returned #{ret.inspect}")
	      ret
      end
      
    end
    
  end
end
