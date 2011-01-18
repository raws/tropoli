module Tropoli
  class TestCase < Test::Unit::TestCase
    CONNECTION_DEFAULTS = { :nick => "Raws", :user => "ross", :real => "Ross" }
    
    undef :default_test if respond_to?(:default_test)
    
    def self.test(name, &block)
      define_method "test #{name.inspect}", &block
    end
    
    def connection(options = {})
      options = CONNECTION_DEFAULTS.merge(options)
      Tropoli::TestConnection.new "test", options
    end
  end
end
