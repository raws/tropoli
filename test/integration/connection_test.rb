require "test_helper"

module Tropoli
  class ConnectionTest < IntegrationTest
    test :"pass sent before nick and user if supplied" do
      pass = "s3cr3t"
      connection(:pass => pass).tap do |c|
        assert_sent_from c, "PASS #{pass}"
      end
    end
    
    test :"pass not sent if not supplied" do
      connection.tap do |c|
        assert_not_sent_from c, "PASS"
      end
    end
  end
end
