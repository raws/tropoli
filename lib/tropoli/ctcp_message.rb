module Tropoli
  class CtcpMessage < Message
    attr_accessor :type, :target
    
    def initialize(*args)
      if args.size == 1 && args.first.is_a?(Message)
        parse_message args.first
      elsif !args.empty?
        parse_request *args
      else
        raise ArgumentError, "must supply at least one argument"
      end
    end
    
    def to_m(options = {})
      return nil unless command.present?
      ctcp_params = params.flatten.compact.map { |p| escape(p) }.reject { |p| p.blank? }
      ctcp_params.unshift(command)
      message = "\x01#{ctcp_params.join(" ")}\x01"
      Message.new((options[:type] || type), (options[:target] || target), message)
    end
    
    def to_s(options = {})
      return nil unless command.present?
      to_m(options).to_s
    end
    
    protected
      def parse_request(*args)
        options = DEFAULT_OPTIONS.merge(args.last.is_a?(Hash) ? args.pop : {})
        super *args
        @type = options[:type]
        @target = options[:target]
        @params = params.map { |p| unescape(p) }
      end
      
      def parse_message(message)
        @type = message.command
        @target = message.params.shift.to_s
        line = message.params.last.to_s
        tokens = (line.extract!(/\x01([^\x01\0\r\n]*)\x01/, 1) || "").split(" ")
        @command = tokens.shift.to_s.strip.upcase
        @params = tokens.map { |t| unescape(t) }
      end
    
      def escape(input)
        escapes = ESCAPES.keys.map { |e| Regexp.escape(e) }
        input.to_s.gsub(/#{escapes.join("|")}/) do |match|
          ESCAPES[match] || match
        end
      end
      
      def unescape(input)
        escapes = ESCAPES.values.map { |e| Regexp.escape(e) }
        input.to_s.gsub(/#{escapes.join("|")}/) do |match|
          method = ESCAPES.respond_to?(:key) ? :key : :index
          ESCAPES.send(method, match) || match
        end
      end
    
    DEFAULT_OPTIONS = { :type => "PRIVMSG" }
    ESCAPES = {
      "\x00" => "\\0",
      "\x01" => "\\1",
      "\r"   => "\\r",
      "\n"   => "\\n",
      " "    => "\\@",
      "\\"   => "\\\\"
    }
  end
end
