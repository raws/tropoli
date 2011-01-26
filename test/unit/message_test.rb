require "test_helper"

module Tropoli
  class MessageRequestTest < TestCase
    test :"empty arguments" do
      assert_raise(ArgumentError) { Message.new }
    end
    
    test :"empty command" do
      assert_request :command => "", :params => [], :creates => nil
    end
    
    test :"just a command" do
      assert_request :command => "QUIT", :params => [], :creates => "QUIT\r\n"
      assert_request :command => "QUIT ", :params => [], :creates => "QUIT\r\n"
      assert_request :command => " QUIT", :params => [], :creates => "QUIT\r\n"
    end
    
    test :"a command with params" do
      assert_request :command => "JOIN", :params => ["#channel"], :creates => "JOIN #channel\r\n"
      assert_request :command => "JOIN", :params => ["#channel", "key"], :creates => "JOIN #channel key\r\n"
    end
    
    test :"a command with a trailing param" do
      assert_request :command => "QUIT", :params => ["foo bar"], :creates => "QUIT :foo bar\r\n"
      assert_request :command => "QUIT", :params => [""], :creates => "QUIT :\r\n"
      assert_request :command => "QUIT", :params => [":foo bar"], :creates => "QUIT ::foo bar\r\n"
      assert_request :command => "QUIT", :params => [":foo"], :creates => "QUIT ::foo\r\n"
    end
    
    test :"a command with normal params and a trailing param" do
      assert_request :command => "PRIVMSG", :params => ["nickname", "message with spaces"], :creates => "PRIVMSG nickname :message with spaces\r\n"
      assert_request :command => "PRIVMSG", :params => [":nickname", "message with spaces"], :creates => "PRIVMSG nickname :message with spaces\r\n"
    end
    
    test :"a command with a user source as a param should use the nick" do
      target = Source.new("Raws", "raws", "test")
      assert_request :command => "PRIVMSG", :params => [target, "message with spaces"], :creates => "PRIVMSG Raws :message with spaces\r\n"
    end
    
    def assert_request(options)
      message = Message.new(options[:command], *options[:params])
      assert_equal options[:creates], message.to_s, "when forming a request"
    end
  end
  
  class MessageResponseTest < TestCase
    test :"empty line" do
      assert_response :command => "", :params => [], :from => ""
      assert_response :command => "", :params => [], :from => " "
      assert_response :command => "", :params => [], :from => "\r\n"
      assert_response :command => "", :params => [], :from => " \r\n"
    end
    
    test :"just a command" do
      assert_response :command => "QUIT", :params => [], :from => "QUIT"
      assert_response :command => "QUIT", :params => [], :from => "QUIT "
      assert_response :command => "QUIT", :params => [], :from => " QUIT"
      assert_response :command => "QUIT", :params => [], :from => "quit"
    end
    
    test :"a command with params" do
      assert_response :command => "JOIN", :params => ["#channel"], :from => "JOIN #channel"
      assert_response :command => "JOIN", :params => ["#channel", "key"], :from => "JOIN #channel key"
    end
    
    test :"a command with a trailing param" do
      assert_response :command => "QUIT", :params => ["foo"], :from => "QUIT :foo"
      assert_response :command => "QUIT", :params => ["foo bar"], :from => "QUIT :foo bar"
      assert_response :command => "QUIT", :params => [""], :from => "QUIT :"
    end
    
    test :"a command with normal params and a trailing param" do
      assert_response :command => "PRIVMSG", :params => ["nickname", "message"], :from => "PRIVMSG nickname :message"
      assert_response :command => "PRIVMSG", :params => ["nickname", "message with spaces"], :from => "PRIVMSG nickname :message with spaces"
      assert_response :command => "PRIVMSG", :params => ["nickname", "message"], :from => "PRIVMSG nickname message"
    end
    
    test :"a command with a source" do
      assert_response :command => "QUIT", :params => [], :source => { :nick => "Raws", :user => "ross", :host => "test" }, :from => ":Raws!ross@test QUIT"
      assert_response :command => "PING", :params => [], :source => { :host => "gort.nj.us.doolanshire.net" }, :from => ":gort.nj.us.doolanshire.net PING"
    end
    
    test :"a command with a source should be considered incoming" do
      message = Message.new(":gort.nj.us.doolanshire.net PING")
      assert_equal "gort.nj.us.doolanshire.net", message.source.to_s
      assert message.incoming?
      assert !message.outgoing?
      message = Message.new(":Raws!ross@test PRIVMSG :a message with spaces")
      assert_equal "Raws!ross@test", message.source.to_s
      assert message.incoming?
      assert !message.outgoing?
    end
    
    test :"a command without a source should be considered outgoing" do
      message = Message.new("PRIVMSG #channel :a message with spaces")
      assert_nil message.source
      assert !message.incoming?
      assert message.outgoing?
      message = Message.new("PRIVMSG", "#channel", "a message with spaces")
      assert_nil message.source
      assert !message.incoming?
      assert message.outgoing?
    end
    
    def assert_response(options)
      message = Message.new(options.delete(:from))
      options[:source] = Source.new(options[:source]) if options[:source]
      options.each do |method, value|
        assert_equal value, message.send(method), "when calling method #{method.inspect}"
      end
    end
  end
  
  class MessageCtcpTest < TestCase
    test :"detecting a CTCP request" do
      assert_ctcp :command => "PRIVMSG", :params => ["nickname", "\x01VERSION\x01"]
      assert_ctcp :command => "PRIVMSG", :params => ["nickname", " \x01VERSION\x01"]
      assert_ctcp :command => "PRIVMSG", :params => ["nickname", "\x01VERSION\x01 "]
      assert_ctcp :command => "NOTICE", :params => ["nickname", "\x01VERSION\x01"]
      assert_ctcp :command => "PRIVMSG", :params => ["#channel", "\x01ACTION wonders\x01"]
    end
    
    test :"regular messages should not be considered CTCP requests" do
      assert_not_ctcp :command => "PRIVMSG", :params => ["nickname", "message"]
      assert_not_ctcp :command => "PRIVMSG", :params => ["nickname", "message with spaces"]
      assert_not_ctcp :command => "NOTICE", :params => ["nickname", "message"]
      assert_not_ctcp :command => "PRIVMSG", :params => ["nickname", "\x01VERSION"]
      assert_not_ctcp :command => "PRIVMSG", :params => ["nickname", "VERSION\x01"]
      assert_not_ctcp :command => "JOIN", :params => ["#channel"]
      assert_not_ctcp :command => "JOIN", :params => ["\x01#channel\x01"]
    end
    
    def assert_ctcp(options)
      message = Message.new(options[:command], *options[:params])
      assert message.ctcp?, "should be a CTCP request"
    end
    
    def assert_not_ctcp(options)
      message = Message.new(options[:command], *options[:params])
      assert !message.ctcp?, "should not be a CTCP request"
    end
  end
end
