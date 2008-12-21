

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'test/vm/test_helper'


class TestInstructionsTest < Test::Unit::TestCase
  include TestHelper

  # LES
  def test_les_true
    runvm [:les], [2,3,4]
    assert_stack [2,1]
  end
  def test_les_false
    runvm [:les], [2,4,4]
    assert_stack [2,0]
  end

  # LEQ
  def test_leq_true
    runvm [:leq], [2,3,4]
    assert_stack [2,1]
  end
  def test_leq_true1
    runvm [:leq], [2,4,4]
    assert_stack [2,1]
  end
  def test_leq_false
    runvm [:leq], [2,4,3]
    assert_stack [2,0]
  end

  # LES
  def test_grt_true
    runvm [:grt], [2,4,3]
    assert_stack [2,1]
  end
  def test_grt_false
    runvm [:grt], [2,4,4]
    assert_stack [2,0]
  end

  # LEQ
  def test_geq_true
    runvm [:geq], [2,4,3]
    assert_stack [2,1]
  end
  def test_geq_true1
    runvm [:geq], [2,4,4]
    assert_stack [2,1]
  end
  def test_geq_false
    runvm [:geq], [2,3,4]
    assert_stack [2,0]
  end

  # EQU
  def test_equ_true
    runvm [:equ], [2,4,4]
    assert_stack [2,1]
  end
  def test_equ_false
    runvm [:equ], [2,4,3]
    assert_stack [2,0]
  end
  def test_equ_false1
    runvm [:equ], [2,3,4]
    assert_stack [2,0]
  end

  # NEQ
  def test_neq_true
    runvm [:neq], [2,4,4]
    assert_stack [2,0]
  end
  def test_neq_false
    runvm [:neq], [2,4,3]
    assert_stack [2,1]
  end
  def test_neq_false1
    runvm [:neq], [2,3,4]
    assert_stack [2,1]
  end

end