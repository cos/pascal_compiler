

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'test/vm/test_helper'


class ProcedureInstructionsTest < Test::Unit::TestCase
  include TestHelper

  def test_rbm_prodedure
    runvm [:lodi, 7, :rbm, 3, 1], [2]
    assert_stack [2,7, 3]
  end

  def test_call
    setvm [:lodi, 7, :sub, 1, :call, 2, 2, 9, :not], [1,2,3,4], :ni => 4
    @vm.x
    assert_equal [[9,2]],@vm.base
    assert_stack [1,8,3,4]
    assert_ni 2
  end

  def test_ret
    setvm [:lodi, 7, :not, :ret, :call, 2, 2, 9, :not], [1,8,3,4], :base => [[9,2]], :ni => 3
    @vm.x
    assert_stack [1]
    assert_equal [], @vm.base
    assert_ni 8
  end
end