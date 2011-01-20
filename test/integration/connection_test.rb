require "test_helper"

module Tropoli
  class ConnectionTest < IntegrationTest
    test :"nick and user commands sent to establish connection" do
      options = { :nick => "Tropoli", :user => "tropoli", :real => "Tropoli Bot" }
      connection(options).tap do |c|
        assert_sent_from c, "NICK #{options[:nick]}\r\n"
        assert_sent_from c, "USER #{options[:user]} 0 * :#{options[:real]}\r\n"
      end
    end
    
    test :"pass sent before nick and user if supplied" do
      pass = "s3cr3t"
      connection(:pass => pass).tap do |c|
        assert_sent_from c, "PASS #{pass}\r\n"
      end
    end
    
    test :"pass not sent if not supplied" do
      connection.tap do |c|
        assert_not_sent_from c, "PASS"
      end
    end
    
    test :"adding a class callback" do
      connection.tap do |c|
        callback = proc {}
        c.class.on :privmsg, &callback
        callback.expects :call
        assert_sent_to c, "PRIVMSG Raws :message with spaces\r\n" do
          c.receive_message :privmsg, "Raws", "message with spaces"
        end
      end
    end
    
    test :"adding an instance callback" do
      connection.tap do |c|
        callback = proc {}
        c.on :privmsg, &callback
        callback.expects :call
        assert_sent_to c, "PRIVMSG Raws :message with spaces\r\n" do
          c.receive_message :privmsg, "Raws", "message with spaces"
        end
      end
    end
    
    test :"callbacks should be called once per event" do
      connection.tap do |c|
        callback = proc {}
        c.on :privmsg, &callback
        callback.expects(:call).twice
        assert_sent_to c, "PRIVMSG Raws :here's one message\r\n" do
          c.receive_message :privmsg, "Raws", "here's one message"
        end
        assert_sent_to c, "PRIVMSG Raws :and here's another\r\n" do
          c.receive_message :privmsg, "Raws", "and here's another"
        end
      end
    end
  end
end
