require "test_helper"

module Tropoli
  class TimeTest < TestCase
    test :"Time instances respond to rfc_2822" do
      assert_respond_to Time.new, :rfc_2822
    end
    
    test :"format a UTC date according to RFC 2822" do
      time = Time.new(2011, 7, 31, 0, 0, 0, 0)
      assert_rfc_2822 time, "Sun, 31 Jul 2011 00:00:00 -0000"
      time = Time.new(2011, 7, 31, 7, 31, 8, 0)
      assert_rfc_2822 time, "Sun, 31 Jul 2011 07:31:08 -0000"
    end
    
    test :"format a local date according to RFC 2822" do
      time = Time.new(2011, 7, 31, 0, 0, 0, "-05:00")
      assert_rfc_2822 time, "Sun, 31 Jul 2011 00:00:00 -0500"
      time = Time.new(2011, 7, 31, 7, 31, 8, "-05:00")
      assert_rfc_2822 time, "Sun, 31 Jul 2011 07:31:08 -0500"
    end
    
    def assert_rfc_2822(time, expected)
      assert_equal expected, time.rfc_2822, "should comply to RFC 2822 formatting"
    end
  end
end
