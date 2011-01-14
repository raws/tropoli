require "yaml"

module Tropoli
  class FunctionalTest < IntegrationTest
    CONNECTION_DEFAULTS = {
      :nick => "Tropoli",
      :user => "tropoli",
      :real => "Tropoli Test Bot",
      :port => 6667
    }
    
    attr_reader :options
    
    def setup
      load_options
    end
    
    def teardown
      @options = nil
    end
    
    def connection(options = {})
      options = self.options.merge(options)
      EventMachine.run do
        connection = EventMachine.connect(options[:host], options[:port], FunctionalTestConnection, options)
        yield connection, options
        connection.close_connection_after_writing
        EventMachine.stop_event_loop
      end
    end
    
    %w(nick user real host port).each do |key|
      define_method(key) do
        @options[key.to_sym]
      end
    end
    
    protected
      def load_options
        connection_file = File.join(File.dirname(__FILE__), "..", "..", "functional", "connection.yml")
        begin
          @options = YAML.load_file(connection_file) || {}
        rescue
          puts "Place connection details in #{File.expand_path(connection_file).inspect} to run functional tests."
          exit 1
        end
        
        connection_name = ENV["TROP_CONNECTION"] || @options.keys.first
        @options = CONNECTION_DEFAULTS.merge(@options[connection_name])
      end
  end
end
