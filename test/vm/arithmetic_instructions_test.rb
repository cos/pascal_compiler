

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'test/vm/test_helper'


class ArithmeticInstructionsTest < Test::Unit::TestCase
  include TestHelper

  def test_add
    runvm [:add], [11, 22, 33]
    assert_stack [11,55]
  end
  def test_sub
    runvm [:sub], [14, 22, 33]
    assert_stack [14,11]
  end
  def test_mul
    runvm [:mul], [14, 22, 5]
    assert_stack [14, 110]
  end
  def test_div
    runvm [:div], [14, 11, 22]
    assert_stack [14, 2]
  end
  def test_mod
    runvm [:mod], [14, 11, 25]
    assert_stack [14, 3]
  end
end