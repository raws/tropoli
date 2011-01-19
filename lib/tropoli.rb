$:.unshift File.dirname(__FILE__)

require "eventmachine"
require "socket"

require "tropoli/core_ext/blank"
require "tropoli/core_ext/string"

require "tropoli/concerns/callbacks"

require "tropoli/connection"
require "tropoli/logging"
require "tropoli/message"
