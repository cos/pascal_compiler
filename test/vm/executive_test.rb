# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'vm/executive'
require 'mocha'

class ExecutiveTest < Test::Unit::TestCase
  include VM
  def setup
    @vm = Executive.new([])
  end
  def test_x
    @vm.expects(:test).with().once
    @vm.code = [:test]
    @vm.x
  end
  def test_xx
    @vm.expects(:test).with(23).once
    @vm.code = [:test,23]
    @vm.x
  end
  def test_xxy
    @vm.expects(:test).with(23).once
    @vm.expects(:another).with().once
    @vm.code = [:test,23,:another]
    @vm.execute
  end
end
