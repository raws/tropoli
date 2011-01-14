require "test_helper"

module Tropoli
  class ExtractTest < TestCase
    test :"just a pattern" do
      original = "foobar"
      assert_equal "foo", original.extract!(/foo/)
      assert_equal "bar", original
    end
    
    test :"a pattern with groups" do
      assert_equal "bar", "foobar".extract!(/foo(bar)/, 1)
      assert_equal "bar", "foobar".extract!(/(foo)(bar)/, 2)
    end
  end
end
