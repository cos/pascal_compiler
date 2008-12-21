# To change this template, choose Tools | Templates
# and open the template in the editor.
module VM
  module LogicInstructions
    #  AND
    #
    #  Se aplica operatorul 'si' logic asupra a doua valori din varful stivei.
    #
    #  SP = SP - 1
    #  STIVA[SP].INFO = STIVA[SP].INFO and STIVA[SP + 1].INFO
    #  NI = NI + 1
    
    def and
      s[-2] = (s[-1]&s[-2])
      s.pop
    end


    #  OR
    #
    #  Ca si AND, dar se aplica operatorul 'sau' logic.
    #
    def or
      s[-2] = (s[-1]|s[-2])
      s.pop
    end
    
    #  NOT
    #
    #  Se aplica negatia logica asupra valorii din varful stivei.
    #
    #  STIVA[SP].INFO = not STIVA[SP].INFO
    #  NI = NI + 1

    def not
      s[-1] = ~s[-1]
    end
  end
end
