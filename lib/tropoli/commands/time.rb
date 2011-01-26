module Tropoli
  module Commands
    module Time
      extend Concerns::Callbacks
      
      on :time do |message, connection|
        if message.ctcp? && message.incoming?
          connection.send_ctcp_message :time, ::Time.new.rfc_2822,
                                       :target => message.source,
                                       :type   => :notice
        end
      end
    end
  end
end
