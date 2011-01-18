require "test_helper"

module Tropoli
  class ConnectionTest < IntegrationTest
    test :"nick and user commands sent to establish connection" do
      options = { :nick => "Tropoli", :user => "tropoli", :real => "Tropoli Bot" }
      connection(options).tap do |c|
        assert_sent_from c, "NICK #{options[:nick]}\r\n"
        assert_sent_from c, "USER #{options[:user]} 0 0 :#{options[:real]}\r\n"
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
  end
end
