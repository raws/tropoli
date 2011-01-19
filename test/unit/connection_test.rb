require "test_helper"

module Tropoli
  class ConnectionTest < TestCase
    test :"adding a class callback" do
      block = proc {}
      id = Connection.on "JOIN", &block
      assert_instance_of Hash, Connection.callbacks
      assert_instance_of Hash, Connection.callbacks["JOIN"]
      assert_equal block, Connection.callbacks["JOIN"][id]
    end
    
    test :"adding an instance callback to a connection" do
      connection.tap do |c|
        block = proc {}
        id = c.on "JOIN", &block
        assert_instance_of Hash, c.callbacks
        assert_instance_of Hash, c.callbacks["JOIN"]
        assert_equal block, c.callbacks["JOIN"][id]
      end
    end
  end
end
