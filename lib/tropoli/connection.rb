module Tropoli
  class Connection < EventMachine::Protocols::LineAndTextProtocol
    attr_reader :options
    
    def initialize(options)
      @options = options
    end
    
    def post_init
      log :info, "Opened connection to #{address}:#{port}"
      identify!
    end
    
    def receive_line(line)
      log :debug, "Received", line.inspect
    end
    
    def unbind
      log :info, "Closing connection"
    end
    
    def send_message(message, *args)
      message = [message.to_s.upcase, *args].join(" ")
      send_data message
      log :debug, "Sent", message
    end
    
    def log(level, *args)
      Tropoli.logger.send(level, args.join(" "))
    end
    
    def address
      peer_info[1]
    end
    
    def port
      peer_info[0]
    end
    
    protected
      def peer_info
        @peer_info ||= Socket.unpack_sockaddr_in(get_peername)
      end
      
      def identify!
        send_message :pass, options[:pass] if options[:pass]
        send_message :nick, options[:nick]
        send_message :user, options[:user], 0, 0, ":#{options[:real]}"
      end
  end
end
