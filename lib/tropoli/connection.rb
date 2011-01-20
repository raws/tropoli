module Tropoli
  class Connection < EventMachine::Protocols::LineAndTextProtocol
    extend Concerns::Callbacks
    include Concerns::Callbacks
    
    attr_reader :options
    attr_writer :logger
    
    def initialize(options)
      super
      @options = options
    end
    
    def post_init
      log :info, "Opened connection to #{options[:host]}:#{options[:port]}"
      identify!
    end
    
    def receive_line(line)
      message = Message.new(line)
      distribute message
      log :debug, "Received", message.to_s.inspect
    end
    
    def unbind
      log :info, "Closing connection"
    end
    
    def send_message(message, *args)
      message = Message.new(message, *args) unless message.is_a?(Message)
      send_data message.to_s
      distribute message
      log :debug, "Sent", message.to_s.inspect
    end
    
    def logger
      @logger || Tropoli.logger
    end
    
    def log(level, *args)
      logger.send(level, args.join(" "))
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
        send_message :user, options[:user], 0, "*", options[:real]
      end
      
      def distribute(message)
        [self.callbacks, self.class.callbacks].each do |callbacks|
          (callbacks[message.command] || {}).each do |id, callback|
            callback.call(message, self, id)
          end
        end unless message.command.blank?
      end
  end
end
