require 'minitest_helper'

class TestHAL::S3 < MiniTest::Unit::TestCase
  def test_that_it_has_a_version_number
    refute_nil ::HAL::S3::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
