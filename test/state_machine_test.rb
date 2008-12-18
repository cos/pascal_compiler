$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'state_machine'

class StateMachineTest < Test::Unit::TestCase
  def setup
    @sm  = StateMachine.new
  end

  def test_normal
    @sm.put('3')
    assert_equal :integer, @sm.state
  end

  def test_syntax_error
    assert_raise StateMachine::LexicalError do
      @sm.put('#')
    end
  end
end