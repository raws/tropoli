require "test_helper"

module Tropoli
  class ConnectionTest < FunctionalTest
    test :"connecting to a server and sending some commands" do
      connection do |c|
        pass_method = options[:pass] ? :assert_sent_from : :assert_not_sent_from
        send pass_method, c, "PASS"
        
        assert_sent_from c, "NICK #{nick}\r\n"
        assert_sent_from c, "USER #{user} 0 * #{":" if real =~ /\s/}#{real}\r\n"
        
        channel = "#perkele"
        assert_sent_from c, "JOIN #{channel}\r\n" do
          c.send_message :join, "#{channel}"
        end
        assert_sent_from c, "PRIVMSG #{channel} :I am a giant bucket\r\n" do
          c.send_message :privmsg, "#{channel}", "I am a giant bucket"
        end
        assert_sent_from c, "PART #{channel}\r\n" do
          c.send_message :part, "#{channel}"
        end
        
        assert_sent_from c, "QUIT :See you next time!\r\n" do
          c.send_message :quit, "See you next time!"
        end
      end
    end
  end
end
