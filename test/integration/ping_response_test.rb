require "test_helper"

module Tropoli
  class PingResponseTest < IntegrationTest
    test :"responding to a PING message" do
      connection.tap do |c|
        assert_sent_from c, "PONG gort.nj.us.doolanshire.net" do
          c.receive_message :ping, "gort.nj.us.doolanshire.net"
        end
        assert_sent_from c, "PONG gort.nj.us.doolanshire.net blat.ma.es.doolanshire.net" do
          c.receive_message :ping, "gort.nj.us.doolanshire.net", "blat.ma.es.doolanshire.net"
        end
      end
    end
  end
end
