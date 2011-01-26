module Tropoli
  class Connection < EventMachine::Protocols::LineAndTextProtocol
    extend Concerns::Callbacks
    include Concerns::Callbacks
    
    include Commands::Time
    
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
      message = CtcpMessage.new(message) if message.ctcp?
      log :debug, "Received", message.to_s.inspect
      distribute message
    end
    
    def unbind
      log :info, "Closing connection"
    end
    
    def send_message(message, *args)
      message = Message.new(message, *args) unless message.kind_of?(Message)
      send_data message.to_s
      log :debug, "Sent", message.to_s.inspect
      distribute message
    end
    
    def send_ctcp_message(message, *args)
      message = CtcpMessage.new(message, *args) unless message.is_a?(CtcpMessage)
      send_message message
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
        [self, *self.class.ancestors].map do |provider|
          provider.respond_to?(:callbacks) ? provider.callbacks : nil
        end.compact.each do |callbacks|
          (callbacks[message.command] || {}).each do |id, callback|
            callback.call(message, self, id)
          end
        end unless message.command.blank?
      end
  end
end
