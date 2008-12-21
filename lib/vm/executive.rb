require 'types'
require 'vm/instructions'

module VM
  class Executive
    include Instructions
    def initialize(code)      
      @code = code
      
      @stack = []
      @base = []
      @rx = 0
      @ni = 0
      @st = :start
    end

    def execute
      @st = :active
      while(self.ni<code.length)
        x
        break if (@st == :stop || @st == :err)
      end      
    end

    # TODO: make this private in production
    public

    attr_accessor :stack
    attr_accessor :code
    attr_accessor :rx
    attr_accessor :ni
    attr_accessor :st
    attr_accessor :ie
    attr_accessor :base
    
    def s;  @stack;  end
    def s=(s); @stack = s end
    def sp
      s.length - 1
    end

    def x
      if(code[ni].is_a? Symbol)
          args = []
          for j in (ni+1...code.length)
            break if(code[j].is_a? Symbol)
            args << code[j]
          end
          @jump = false
          begin
          method(code[ni]).call(*args)
#          rescue NameError => e
#            err = ExecuteError.new("Unidentified instruction:"+e.to_s[/`.*?'/]+' at instruction #'+ni.to_s)
#            err.set_backtrace(e.backtrace)
#            raise err
          end
          self.ni += args.length + 1 unless @jump
      else
          raise ExecuteError.new('Tried to execute non-instruction:`'+code[ni].to_s+'` at #'+ni.to_s+'. Probably an instruction had a wrong number of arguments at the previous step')
      end
    end
  end
  class ExecuteError < RuntimeError
    
  end
end