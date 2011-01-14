module Tropoli
  class FunctionalTestConnection < Connection
    def sent_data
      @sent_data ||= []
    end
    
    def send_data(data)
      super data
      sent_data << data
    end
    
    def received_data
      @received_data ||= []
    end
    
    def receive_line(line)
      super line
      received_data << line
    end
  end
end
