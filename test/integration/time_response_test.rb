require "test_helper"

module Tropoli
  class TimeResponseTest < IntegrationTest
    test :"responding to a CTCP TIME request" do
      connection.tap do |c|
        pattern = /NOTICE Raws :\x01TIME [A-Za-z]{3},\\@\d{2}\\@[A-Za-z]{3}\\@\d{4}\\@\d{2}:\d{2}:\d{2}\\@[-+]\d{4}\x01\r\n/
        assert_sent_from c, pattern do
          c.receive_line ":Raws!ross@test PRIVMSG Tropoli \x01TIME\x01\r\n"
        end
      end
    end
  end
end
