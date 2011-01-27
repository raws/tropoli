module Tropoli
  module Commands
    module Version
      extend Concerns::Callbacks
      
      on :version do |message, connection|
        if message.ctcp? && message.incoming?
          params = ["Tropoli", "Ruby #{RUBY_VERSION}", "http://github.com/raws/tropoli"]
          connection.send_ctcp_message :version, *params, :target => message.source, :type => :notice
        end
      end
    end
  end
end
