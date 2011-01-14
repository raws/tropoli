begin
  require "tropoli"
  require "test/unit"
rescue LoadError => e
  if require "rubygems"
    retry
  else
    raise e
  end
end

$:.unshift File.join(File.dirname(__FILE__), "lib")

require "logger"
TEST_LOG_DIR = File.expand_path(File.join(File.dirname(__FILE__), "..", "log"))
Tropoli.logger = Logger.new(File.open(File.join(TEST_LOG_DIR, "test.log"), "w+"))

require "tropoli/test_case"
require "tropoli/test_connection"
require "tropoli/functional_test_connection"
require "tropoli/integration_test"
require "tropoli/functional_test"
