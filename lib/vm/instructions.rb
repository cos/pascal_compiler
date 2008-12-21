# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'vm/stack_instructions'
require 'vm/jump_instructions'
require 'vm/test_instructions'
require 'vm/arithmetic_instructions'
require 'vm/procedure_instructions'
require 'vm/logic_instructions'
require 'vm/misc_instructions'

module VM
  module Instructions
    include StackInstructions
    include JumpInstructions    
    include TestInstructions
    include ArithmeticInstructions
    include ProcedureInstructions
    include LogicInstructions
    include MiscInstructions
  end
end
