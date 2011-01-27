module Tropoli
  module Commands
    module Ping
      extend Concerns::Callbacks
      
      on :ping do |message, connection|
        next unless message.incoming?
        if message.ctcp?
          connection.send_ctcp_message :pong, *message.params, :target => message.source, :type => :notice
        else
          connection.send_message :pong, *message.params
        end
      end
    end
  end
end
