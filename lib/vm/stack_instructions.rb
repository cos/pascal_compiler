# To change this template, choose Tools | Templates
# and open the template in the editor.

module VM
  module StackInstructions
    # LOD nivel adrel
    # Incarca in varful stivei de lucru valoarea aflata la adresa calculata pe baza argumentelor.
    #
    #  i = VBAZA 
    #  while nivel <> BAZA[i].LEVEL do
    #  i = i - 1
    #  endwhile 
    #  adr = BAZA[i].BLOC + adrel     //(**) 
    #  while STIVA[adr].TIP_NOD = 'adresa ' do
    #  adr = STIVA[adr].INFO
    #  endwhile 
    #  SP = SP + 1 
    #  STIVA[SP] = STIVA[adr] 
    #  NI = NI + 3

    def lod(level, addr1)
      b = base.find {|b| b[0] == level}
      addr = b[1]+addr1
      addr = s[addr] while s[addr].is_a? StackAddress
      s << s[addr]
    end

    # LODI iconst
    # Incarca in varful stivei de lucru constanta aflata in pozitia iconst din TAB_CONST.
    def lodi(const)
      s << const
    end

    # LODA nivel adrel
    # Incarca in varful stivei de lucru adresa calculata pe baza argumentelor.

    def loda(level, addr1)
      b = base.find {|b| b[0] == level}
      addr = StackAddress.new(b[1]+addr1)
      s << addr
    end

    def lodx(level, addr1)
      lod(level, addr1+rx)
    end

    # LODX nivel adrel
    # Ca si LOD, dar la calculul adresei se include si continutul registrului de index. Implementarea este similara cu cea a instructiunii LOD, singura modificare apare in linia (**) si anume:
    # adr = BAZA[i].BLOC + adrel + RX

    # COPI
    # Se creaza un nod nou in varful stivei de lucru completat cu continutul vechiului varf.

    def copi
      s << s.last
    end

    # STO
    # Depune valoarea aflata in varful stivei de lucru la adresa indicata de nodul de sub varf si apoi elimina doua noduri din stiva .
    def sto
      s[s[-2]] = s[-1]
      self.s = s[0..-3]
    end

    # MVRX
    # Muta in registrul de index valoarea din varful stivei de lucru.
    def mvrx
      self.rx = s.pop
    end

    # RED
    # Elimina un nod din stiva de lucru.
    def red
      s.pop
    end
  end
end