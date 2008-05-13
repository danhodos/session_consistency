require 'test/unit'
require File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'config', 'environment')
require 'test_help'

ActionController::TestRequest.class_eval do
  include DanHodos::SessionConsistency::TestExtensions
end