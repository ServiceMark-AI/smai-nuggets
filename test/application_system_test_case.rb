require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :rack_test

  include EmailHelpers
  include ActionMailer::TestHelper
end
