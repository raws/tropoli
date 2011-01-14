require "test_helper"

module Tropoli
  class RequestTest < TestCase
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
    
    def assert_request(options)
      message = Message.new(options[:command], *options[:params])
      assert_equal options[:creates], message.to_s, "when forming a request"
    end
  end
  
  class ResponseTest < TestCase
    test :"empty line" do
      assert_response :command => "", :params => [], :from => ""
      assert_response :command => "", :params => [], :from => " "
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
    
    def assert_response(options)
      message = Message.new(options.delete(:from))
      options.each do |method, value|
        assert_equal value, message.send(method), "when calling method #{method.inspect}"
      end
    end
  end
end
