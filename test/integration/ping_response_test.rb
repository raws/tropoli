require "test_helper"

module Tropoli
  class PingResponseTest < IntegrationTest
    test :"responding to a PING message" do
      connection.tap do |c|
        assert_sent_from c, "PONG gort.nj.us.doolanshire.net" do
          c.receive_line ":gort.nj.us.doolanshire.net PING gort.nj.us.doolanshire.net\r\n"
        end
        assert_sent_from c, "PONG gort.nj.us.doolanshire.net blat.ma.es.doolanshire.net" do
          c.receive_line ":server PING gort.nj.us.doolanshire.net blat.ma.es.doolanshire.net\r\n"
        end
      end
    end
    
    test :"responding to a CTCP PING request" do
      connection.tap do |c|
        assert_sent_from c, "NOTICE Raws :\x01PONG signature\x01\r\n" do
          c.receive_line ":Raws!ross@test PRIVMSG Tropoli :\x01PING signature\x01\r\n"
        end
      end
    end
  end
end
