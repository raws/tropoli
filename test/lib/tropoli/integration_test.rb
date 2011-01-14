module Tropoli
  class IntegrationTest < TestCase
    def capture_sent_data(connection)
      size = connection.sent_data.size
      yield
      connection.sent_data[size..-1]
    end
    
    def assert_sent_from(connection, line, &block)
      sent_data = block ? capture_sent_data(connection, &block) : connection.sent_data
      pattern = /^#{line.is_a?(Regexp) ? line : Regexp.escape(line)}/
      assert sent_data.find { |data| data =~ pattern }, "expected to send #{line.inspect}"
    end
    
    def assert_not_sent_from(connection, line, &block)
      sent_data = block ? capture_sent_data(connection, &block) : connection.sent_data
      pattern = /^#{Regexp.escape(line)}/
      assert sent_data.reject { |data| data !~ pattern }.empty?, "expected not to send #{line.inspect}"
    end
  end
end
