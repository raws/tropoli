require "test_helper"

module Tropoli
  class VersionResponseTest < IntegrationTest
    test :"responding to a CTCP VERSION request" do
      connection.tap do |c|
        assert_sent_from c, /NOTICE Raws :\x01VERSION .+?\x01\r\n/ do
          c.receive_line ":Raws!ross@test PRIVMSG Tropoli \x01VERSION\x01\r\n"
        end
      end
    end
  end
end
