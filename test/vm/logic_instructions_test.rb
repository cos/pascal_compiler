

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'test/vm/test_helper'


class LogicInstructionsTest < Test::Unit::TestCase
  include TestHelper

  def test_and
    runvm [:and], [12, 23, 45]
    assert_stack [12, (23&45)]
  end
  def test_or
    runvm [:or], [12, 23, 45]
    assert_stack [12, (23|45)]
  end
  def test_not
    runvm [:not], [12, 34, 5]
    assert_stack [12, 34, ~5]
  end
end