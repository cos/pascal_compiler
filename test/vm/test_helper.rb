require 'vm/executive'

module TestHelper
  include VM

  def setvm(code, stack = [], args = {})
    @vm = Executive.new(code)
    @vm.s = stack
    @vm.ni = args[:ni] if args[:ni]
    @vm.rx = args[:rx] if args[:rx]
    @vm.base = args[:base] if args[:base]
  end
  
  def runvm(*args)
    setvm(*args)
    @vm.execute
  end

  def assert_stack(value)
    assert_equal value, @vm.s
  end
  def assert_ni(value)
    assert_equal value, @vm.ni
  end
end

