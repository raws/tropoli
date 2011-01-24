module Tropoli
  class Message
    attr_accessor :command, :params
    
    def initialize(*args)
      if args.size > 1
        parse_request *args
      elsif args.size == 1
        parse_response *args
      else
        raise ArgumentError, "must supply at least one argument"
      end
    end
    
    def to_s
      return nil unless command.present?
      message = [command]
      unless params.empty?
        middle_params = params.flatten.compact.map { |p| p.to_s.gsub(/[\0\r\n]/, "") }
        trailing_param = middle_params.pop if params.last =~ /\A:|\s/ || params.last.empty?
        middle_params.map! { |p| p.gsub(/\A:|\s/, "") }
        middle_params.reject! { |p| p.blank? || p =~ /\A[\0\r\n\s]*\z/ }
        message.concat(middle_params)
        message << ":#{trailing_param}" if trailing_param
      end
      message.join(" ") << "\r\n"
    end
    
    def ctcp?
      %w(PRIVMSG NOTICE).include?(command) &&
      !params.empty? &&
      params.last.to_s =~ /\A\s*\x01[^\x01\0\r\n]*\x01\s*\z/
    end
    
    protected
      def parse_request(*args)
        @command = args.shift.to_s.strip.upcase
        @params = args
      end

      def parse_response(*args)
        line = args.first.to_s.lstrip.chomp
        prefix = line.extract!(/\A:(\S*?)(?:!(\S+))?(?:@(\S+))?\s+/)
        @command = (line.extract!(/\A\s*(\S+)/, 1) || "").strip.upcase
        @params = (line.extract!(/\A(?:\s+[^:\s]\S*)+/) || "").split(/\s+/)
        params.reject! { |p| p.blank? }
        params << line.extract!(/\A\s*:(.*)\z/, 1)
        params.compact!
      end
  end
end
