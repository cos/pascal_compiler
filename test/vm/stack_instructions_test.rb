

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'test/vm/test_helper'


class StackInstructionsTest < Test::Unit::TestCase
  include TestHelper

  def test_lod
    runvm [:lod, 2, 2], [10,11,12,13,14,15,StackAddress.new(2),17,18,19], :base => [[1,2],[2,4],[3,7]]
    assert_stack [10,11,12,13,14,15,StackAddress.new(2),17,18,19]+[12]
  end
  
  def test_lodi
    runvm [:lodi, 34], [22,33,44]
    assert_equal 34, @vm.s[-1]
  end

  def test_loda
    runvm [:loda, 2, 2], [10,11,12,13,14,15,16,17,18,19], :base => [[1,2],[2,4],[3,7]]
    assert_stack [10,11,12,13,14,15,16,17,18,19]+[StackAddress.new(6)]
  end

  def test_lodx
    runvm [:lodx, 2, 2], [10,11,12,13,14,15,16,17,StackAddress.new(2),19], :base => [[1,2],[2,4],[3,7]], :rx => 2
    assert_stack [10,11,12,13,14,15,16,17,StackAddress.new(2),19]+[12]
  end

  def test_copi
    runvm [:lodi, 34, :copi]
    assert_stack [34,34]
  end

  def test_sto
    runvm [:sto], [44,55,66,1,23]
    assert_equal [44,23,66], @vm.s
  end
  def test_mvrx
    runvm [:mvrx], [23,56], :rx => 22
    
    assert_equal @vm.rx, 56
    assert_equal @vm.s, [23]
  end
  def test_red
    runvm [:red], [23, 56]
    assert_stack [23]
  end
end