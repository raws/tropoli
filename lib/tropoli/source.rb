module Tropoli
  class Source
    include Comparable
    
    attr_reader :nick, :user, :host
    
    def initialize(*args)
      args.compact!
      if args.size == 1 && args.first.is_a?(Hash)
        options = args.first
        @nick = options[:nick].to_s.strip if options[:nick]
        @user = options[:user].to_s.strip if options[:user]
        @host = options[:host].to_s.strip
      elsif args.size == 1
        @host = args.first.to_s.strip
      elsif args.size == 3
        @nick, @user, @host = *args.map { |arg| arg.to_s.strip }
      else
        raise ArgumentError, "wrong number of arguments (#{args.size} for one or three)"
      end
    end
    
    def server?
      host && !(nick && user)
    end
    
    def user?
      !server?
    end
    
    def to_s
      if server?
        host
      else
        "#{nick}!#{user}@#{host}"
      end
    end
    
    def <=>(other)
      to_s <=> other.to_s
    end
  end
end
