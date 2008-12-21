# To change this template, choose Tools | Templates
# and open the template in the editor.
module VM
  module JumpInstructions
    # UJP adr
    # Salt neconditionat la instructiunea aflata la adresa adr in TAB_COD.
    def ujp(add)
      self.ni = add
      @jump = true
    end

    # FJP adr
    # If stack top is 0 jump to adr, continue otherwise
    # pop stack in either case
    def fjp(adr)
      if s[-1]==0
        @jump = true
        self.ni = adr
      end
      s.pop
    end
  end
end
