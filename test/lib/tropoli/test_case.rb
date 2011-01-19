module Tropoli
  class TestCase < Test::Unit::TestCase
    CONNECTION_DEFAULTS = {
      :host => "test",
      :port => 6667,
      :nick => "Tropoli",
      :user => "tropoli",
      :real => "Tropoli Bot"
    }
    
    undef :default_test if respond_to?(:default_test)
    
    def self.test(name, &block)
      define_method "test #{name.inspect}", &block
    end
    
    def connection(options = {})
      options = CONNECTION_DEFAULTS.merge(options)
      Tropoli::TestConnection.new "test", options
    end
    
    def assert_instance_of(expected_type, object)
      assert_equal expected_type, object.class
    end
  end
end
