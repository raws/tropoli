module Tropoli
  module Commands
    module Ping
      extend Concerns::Callbacks
      
      on :ping do |message, connection|
        connection.send_message :pong, *message.params
      end
    end
  end
end
