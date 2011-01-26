module Tropoli
  module Commands
    module Time
      extend Concerns::Callbacks
      
      on :time do |message, connection|
        if message.ctcp? && message.incoming?
          response = ::Time.new.rfc_2822
          connection.send_ctcp_message :time, response, :target => message.source, :type => :notice
        end
      end
    end
  end
end
