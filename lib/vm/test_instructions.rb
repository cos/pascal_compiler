# To change this template, choose Tools | Templates
# and open the template in the editor.
module VM
  module TestInstructions
    # LES
    # Se testeaza daca valoarea de sub varful stivei de lucru se afla in relatia
    # '<' cu valoarea din varful stivei. Apoi cele doua valori se elimina si in
    # locul lor se depune valoarea 1 (adevarat) - daca relatia exista, respectiv 0 - daca relatia nu exista .
    #  SP = SP - 1
    #  if STIVA[SP].INFO < STIVA[SP + 1].INFO then
    #  STIVA[SP].INFO = 1
    #  else
    #  STIVA[SP].INFO = 0
    #  endif
    #  STIVA[SP].TIP_NOD = 'intreg'
    #  NI = NI + 1

    def les
      s[-2] = s[-2]<s[-1] ? 1 : 0
      s.pop
    end

    def leq
      s[-2] = s[-2]<=s[-1] ? 1 : 0
      s.pop
    end

    def grt
      s[-2] = s[-2]>s[-1] ? 1 : 0
      s.pop
    end

    def geq
      s[-2] = s[-2]>=s[-1] ? 1 : 0
      s.pop
    end

    def equ
      s[-2] = s[-2]==s[-1] ? 1 : 0
      s.pop
    end

    def neq
      s[-2] = s[-2]!=s[-1] ? 1 : 0
      s.pop
    end    
  end
end
