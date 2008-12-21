# To change this template, choose Tools | Templates
# and open the template in the editor.
module VM
  module ProcedureInstructions
    # RBM dim_var nr_loc
    #
    # Rezervare marcaj de bloc in stiva de lucru, inaintea rezolvarii unui apel de subprogram. Argumentul nr_loc poate fi: 2 - pentru functii, respectiv 1 - pentru proceduri. Marcajul de bloc va servi pentru:
    #
    # memorarea rezultatului returnat, in cazul functiilor;
    # memorarea adresei de revenire, inainte de a da controlul subprogramului apelat.
    # Pana la rezolvarea propriu-zisa a apelului (executia unei instructiuni CALL), marcajul de bloc pastreaza valoarea dim_var, necesara pentru rezervarea in stiva a spatiului pentru variabilele locale ale subprogramului.
    # Se mentioneaza faptul ca deasupra marcajului de bloc, in stiva de lucru se va afla blocul rezervat subprogramului apelat. Prin urmare, in cazul functiilor, locatia in care se memoreaza rezultatul returnat se afla la deplasament (-2) fata de inceputul blocului de lucru. Acesta este motivul pentru care campul ADREL din TS s-a completat cu valoarea -2 la numele de functii (v. Lucrarea nr.8).
    # SP = SP + nr_loc
    # STIVA[SP].INFO = dim_var
    # NI = NI + 3

    def rbm(dim_var, nr_loc)
      stack << nil if nr_loc == 2
      stack << dim_var
    end


    #  CALL adr_salt nr_par nivel
    #  Apel de subprogram: completeaza un nod nou in stiva BAZA, rezerva in stiva de lucru spatiu pentru variabilele locale, memoreaza adresa de revenire si executa saltul la codul subprogramului apelat.
    #
    #  VBAZA = VBAZA + 1
    #  BAZA[VBAZA].LEVEL = nivel
    #  BAZA[VBAZA].BLOC = SP - nr_par + 1
    #  SP = SP + STIVA[BAZA[VBAZA].BLOC -1].INFO
    #  STIVA[BAZA[VBAZA].BLOC - 1].INFO = NI + 4
    #  NI = adr_salt
    
    def call(jmp_addr, no_params, level)      
      base << [level, sp-no_params+1]
      s[base.last[1]-1] = ni + 4
      self.ni = jmp_addr
      @jump = true
    end
    

    #  RET
    #
    #  Revenire dintr-un subprogram.
    #
    #  SP = BAZA[VBAZA].BLOC - 2
    #  NI = STIVA[SP + 1]
    #  VBAZA = VBAZA - 1

    def ret      
      self.s = s[0..(base.pop[1]-1)]
      self.ni = s.pop
      @jump = true
    end

    # XXX: FCALL adr_salt nr_par nivel
    # Este o instructiune fictiva utilizata pentru rezolvarea apelurilor de subprograme care apar intr-un text sursa inainte de a se cunoaste adresa de start a subprogramelor respective (v. Lucrarea nr.11). Practic toate instructiunile FCALL din TAB_COD sunt inlocuite cu instructiuni CALL, inainte ca programul obiect sa fie lansat in executie. Se poate spune, deci, ca aceasta instructiune nici nu este recunoscuta de masina virtuala.
  end
end
