$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'test/vm/test_helper'

class JumpInstructionsTest < Test::Unit::TestCase
  include TestHelper

  def test_ujp
    runvm [:ujp, 22]
    assert_ni 22
  end

  def test_fjp_with_jump
    setvm [:bla, :bla, :fjp, 1],[23,354,0], :ni => 2
    @vm.x
    assert_ni 1
    assert_stack [23,354]
  end
  def test_fjp_without_jump
    setvm [:bla, :bla, :fjp, 1],[23,354,7], :ni => 2
    @vm.x
    assert_ni 4
    assert_stack [23,354]
  end
end
