

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'test/vm/test_helper'


class MiscInstructionsTest < Test::Unit::TestCase
  include TestHelper

  def test_stop
    runvm [:lodi, 4, :stop, :lodi, 5, :not], []
    assert_equal :stop, @vm.st
    assert_ni 3
    assert_stack [4]
  end

  def test_err
    runvm [:lodi, 4, :lodi, 7, :err, 3, :lodi, 5, :not], []
    assert_equal :err, @vm.st
    assert_ni 6
    assert_stack [4,7]
    assert_equal 3, @vm.ie
  end

end