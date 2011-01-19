module Tropoli
  module Concerns
    module Callbacks
      def callbacks
        @callbacks ||= {}
      end
      
      def on(command, &block)
        command = command.to_s.strip.upcase
        generate_callback_id.tap do |id|
          (callbacks[command] ||= {})[id] = block
        end
      end
      
      protected
        def generate_callback_id
          @callback_id ||= 0
          @callback_id += 1
        end
    end
  end
end
