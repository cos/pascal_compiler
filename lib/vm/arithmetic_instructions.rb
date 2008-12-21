# To change this template, choose Tools | Templates
# and open the template in the editor.
module VM
  module ArithmeticInstructions
    # ADD
    # Insumeaza valoarea de sub varful stivei cu valoarea din varf, elimina operanzii din stiva si depune rezultatul in varf.
    # SP = SP - 1
    # STIVA[SP].INFO = STIVA[SP].INFO + STIVA[SP + 1].INFO
    # *eventuale verificari privind depasirea limitelor de reprezentare a numerelor
    # NI = NI + 1
    # Obs: tipul rezultatului obtinut depinde de tipul operanzilor. In majoritatea cazurilor operanzii sunt de acelasi tip (la generarea de cod este prevazuta efectuarea conversiilor daca operanzii sunt diferiti ca tip). Un caz particular insa , il constituie calculul de adresa pentru elementele de tablouri sau pentru campuri de structura (v. Lucrarea nr.11), cand apare adunarea unei adrese cu un deplasament (numar intreg). In aceste situatii tipul rezultatului va fi 'adresa'.
    def add
      s[-2] = s[-1]+s[-2]
      s.pop
    end

    # SUB, MUL, DIV, MOD
    # Ca si ADD, dar operatorii aritmetici sunt respectiv: -, *, / si modulo. La impartiri se vor efectua in plus verificari privind valoarea impartitorului.
    def sub
      s[-2] = s[-1]-s[-2]
      s.pop
    end
    def mul
      s[-2] = s[-1]*s[-2]
      s.pop
    end
    def div
      s[-2] = s[-1]/s[-2]
      s.pop
    end
    def mod
      s[-2] = s[-1]%s[-2]
      s.pop
    end    
  end
end