# To change this template, choose Tools | Templates
# and open the template in the editor.
module VM
  module MiscInstructions
    # ---------------------------
    # Stop stuff
    # ---------------------------

    # STOP
    # Oprire normala a programului.
    # ST = 'stop'

    def stop
      @st = :stop
    end

    #  ERR cod
    #  Forteaza oprirea programului, pozitionand registrul de stare pe err si incarcand in registrul indicator de eroare valoarea cod.
    #  ST = 'err'
    #  IE = cod

    def err(cod)
      @st = :err
      @ie = cod
    end

    # ---------------------------
    # Conversion stuff
    # ---------------------------

    #
    #  XXX CONV tip nr_loc
    #  !!! irelevanta la modul in care e construit compilatorul
    #  Realizeaza conversia la tipul indicat a valorii aflate in varful stivei (daca nr_loc este 0) sau sub varful stivei (daca nr_loc este 1).
    #
    #  *conversie la tip a continutului locat iei STIVA[SP - nr_loc]
    #  NI = NI + 3
    #   C.10. Instructiuni logice
    #
  end
end
