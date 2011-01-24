require "test_helper"

module Tropoli
  class CtcpMessageRequestTest < TestCase
    test :"empty arguments" do
      assert_raise(ArgumentError) { CtcpMessage.new }
    end
    
    test :"empty command" do
      assert_request :command => "", :params => [], :creates => nil
      assert_request :command => " ", :params => [], :creates => nil
    end
    
    test :"just a command" do
      assert_request :type => "PRIVMSG", :target => "nickname", :command => "VERSION", :params => [], :creates => "PRIVMSG nickname \x01VERSION\x01\r\n"
      assert_request :type => "PRIVMSG", :target => "nickname", :command => " VERSION", :params => [], :creates => "PRIVMSG nickname \x01VERSION\x01\r\n"
      assert_request :type => "PRIVMSG", :target => "nickname", :command => "VERSION ", :params => [], :creates => "PRIVMSG nickname \x01VERSION\x01\r\n"
      assert_request :type => "NOTICE", :target => "nickname", :command => "VERSION", :params => [], :creates => "NOTICE nickname \x01VERSION\x01\r\n"
    end
    
    test :"a command with params" do
      assert_request :type => "PRIVMSG", :target => "#channel", :command => "ACTION", :params => ["wonders"], :creates => "PRIVMSG #channel :\x01ACTION wonders\x01\r\n"
      assert_request :type => "PRIVMSG", :target => "#channel", :command => "ACTION", :params => ["thinks about it"], :creates => "PRIVMSG #channel :\x01ACTION thinks\\@about\\@it\x01\r\n"
      assert_request :type => "PRIVMSG", :target => "#channel", :command => "ACTION", :params => ["thinks about \\it\\"], :creates => "PRIVMSG #channel :\x01ACTION thinks\\@about\\@\\\\it\\\\\x01\r\n"
      assert_request :type => "PRIVMSG", :target => "nickname", :command => "DCC", :params => ["CHAT", "clear", "127.0.0.1", "1234"], :creates => "PRIVMSG nickname :\x01DCC CHAT clear 127.0.0.1 1234\x01\r\n"
    end
    
    def assert_request(options)
      expected = options.delete(:creates)
      command = options.delete(:command)
      params = options.delete(:params)
      message = CtcpMessage.new(command, *params, options)
      assert_equal expected, message.to_s, "when forming a CTCP request"
    end
  end
  
  class CtcpMessageResponseTest < TestCase
    test :"empty line" do
      assert_response :type => "PRIVMSG", :target => "nickname", :command => "", :params => [], :from => "PRIVMSG nickname :\x01\x01\r\n"
      assert_response :type => "PRIVMSG", :target => "nickname", :command => "", :params => [], :from => "PRIVMSG nickname :\x01 \x01\r\n"
    end
    
    test :"just a command" do
      assert_response :type => "PRIVMSG", :target => "nickname", :command => "VERSION", :params => [], :from => "PRIVMSG nickname :\x01VERSION\x01\r\n"
      assert_response :type => "PRIVMSG", :target => "nickname", :command => "VERSION", :params => [], :from => "PRIVMSG nickname :\x01 VERSION\x01\r\n"
      assert_response :type => "PRIVMSG", :target => "nickname", :command => "VERSION", :params => [], :from => "PRIVMSG nickname :\x01VERSION \x01\r\n"
      assert_response :type => "PRIVMSG", :target => "nickname", :command => "VERSION", :params => [], :from => "PRIVMSG nickname : \x01VERSION\x01\r\n"
      assert_response :type => "PRIVMSG", :target => "nickname", :command => "VERSION", :params => [], :from => "PRIVMSG nickname :\x01VERSION\x01 \r\n"
      assert_response :type => "NOTICE", :target => "nickname", :command => "VERSION", :params => [], :from => "NOTICE nickname :\x01VERSION\x01\r\n"
    end
    
    test :"a command with params" do
      assert_response :type => "PRIVMSG", :target => "nickname", :command => "ACTION", :params => ["wonders"], :from => "PRIVMSG nickname :\x01ACTION wonders\x01\r\n"
      assert_response :type => "PRIVMSG", :target => "nickname", :command => "ACTION", :params => ["thinks about it"], :from => "PRIVMSG nickname :\x01ACTION thinks\\@about\\@it\x01\r\n"
      assert_response :type => "PRIVMSG", :target => "nickname", :command => "ACTION", :params => ["thinks about \\it\\"], :from => "PRIVMSG nickname :\x01ACTION thinks\\@about\\@\\\\it\\\\\x01\r\n"
      assert_response :type => "PRIVMSG", :target => "nickname", :command => "DCC", :params => ["CHAT", "clear", "127.0.0.1", "1234"], :from => "PRIVMSG nickname :\x01DCC CHAT clear 127.0.0.1 1234\x01\r\n"
    end
    
    def assert_response(options)
      message = Message.new(options.delete(:from))
      assert message.ctcp?, "should be a CTCP request"
      message = CtcpMessage.new(message)
      options.each do |method, value|
        assert_equal value, message.send(method), "when calling method #{method.inspect}"
      end
    end
  end
end
