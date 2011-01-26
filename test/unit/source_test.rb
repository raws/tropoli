require "test_helper"

module Tropoli
  class SourceTest < TestCase
    test :"creating a source using a hash" do
      expected = { :nick => "Tropoli", :user => "tropoli", :host => "test" }
      assert_source expected, :nick => "Tropoli", :user => "tropoli", :host => "test"
      assert_source expected, :nick => "Tropoli ", :user => "tropoli ", :host => "test "
      assert_source expected, :nick => " Tropoli", :user => " tropoli", :host => " test"
    end
    
    test :"creating a source using discrete arguments" do
      expected = { :nick => "Tropoli", :user => "tropoli", :host => "test" }
      assert_source expected, "Tropoli", "tropoli", "test"
      assert_source expected, "Tropoli ", "tropoli ", "test "
      assert_source expected, " Tropoli", " tropoli", " test"
    end
    
    test :"whether a source represents a user or a server" do
      source = Source.new("gort.nj.us.doolanshire.net")
      assert source.server?
      assert !source.user?
      source = Source.new("Tropoli", "tropoli", "test")
      assert !source.server?
      assert source.user?
    end
    
    test :"turning a source into a string" do
      assert_source "Tropoli!tropoli@test", :nick => "Tropoli", :user => "tropoli", :host => "test"
      assert_source "Tropoli!tropoli@test", :nick => "Tropoli ", :user => "tropoli ", :host => "test "
      assert_source "Tropoli!tropoli@test", :nick => " Tropoli", :user => " tropoli", :host => " test"
    end
    
    test :"comparing sources" do
      source_a = Source.new("Tropoli", "tropoli", "test")
      source_b = Source.new("Tropoli", "tropoli", "test")
      assert_equal source_a, source_b
      source_a = Source.new("Tropoli", "tropoli", "test")
      source_b = Source.new("Tropoli ", "tropoli ", "test ")
      assert_equal source_a, source_b
      source_a = Source.new("Tropoli", "tropoli", "test")
      source_b = Source.new(" Tropoli", " tropoli", " test")
      assert_equal source_a, source_b
      source_a = Source.new("Tropoli", "tropoli", "test")
      source_b = Source.new("Raws", "ross", "test")
      assert_not_equal source_a, source_b
    end
    
    def assert_source(expected, *options)
      source = options.is_a?(Hash) ? Source.new(options) : Source.new(*options)
      if expected.is_a?(String)
        assert_equal expected, source.to_s
      elsif expected.is_a?(Hash)
        expected.each do |method, value|
          assert_equal value, source.send(method), "when calling method #{method.inspect}"
        end
      end
    end
  end
end
