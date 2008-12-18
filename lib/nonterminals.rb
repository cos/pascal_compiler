require 'atoms'

module Nonterminals
  include Atom

  def non_terminals
    return @non_terminals if @non_terminals
    @non_terminals =
    {
    :program_sursa =>
        [[Keyword.program, Identifier, Limit[';'], :bloc, Limit['.']]],
    :bloc =>
        [[:sectiune_const, :sectiune_var, :sectiune_decl_subprog, :instr_comp]],
    :sectiune_const =>
        [[Keyword.const , :lista_decl_const],
        [:epsilon]],
    :lista_decl_const =>
        [[:declar_const],
        [:lista_decl_const, :declar_const]],
    :sectiune_var =>
        [[:lista_decl_var],
         [:epsilon]],
    :lista_decl_var =>
        [[:declar_var] ,
         [:lista_declar_var, :declar_var]],
    :sectiune_decl_subprog =>
        [[:lista_decl_subprog],
         [:epsilon]],
    :lista_decl_subprog =>
        [[:decl_subprog],
         [:lista_decl_subprog, :decl_subprog]],
    :decl_subprog =>
        [[:declar_functie],
         [:declar_procedura]],
    :declar_const =>
        [[Identifier, Operator['='], :expresie_statica, Limit[';']]],
    :declar_var =>
        [[:lista_id, Limit[':'], :tip, Limit[';']]],
    :lista_id =>
        [[Identifier],
         [:lista_id, Identifier]],
    :tip =>
        [[:tip_simplu],
         [:tip_tablou],
         [:tip_struct]],
    :tip_simplu =>
        [[Keyword.integer],
         [Keyword.real],
         [Keyword.char],
         [Keyword.string]],
    :tip_tablou =>
        [[Keyword.array, Operator['['], :expresie_statica, Operator['.'], Operator['.'], :expresie_statica, Operator[']'], Keyword.of, :tip_simplu]],
    :tip_struct =>
        [[Keyword.record, :lista_camp, Keyword.end ]],
    :lista_camp =>
        [[:decl_simpla],
         [:lista_camp, Limit[';'], :decl_simpla]],
    :decl_simpla =>
        [[:lista_id, Limit[':'], :tip_simplu]],
    :declar_functie =>
        [[Keyword.function, :antet_subprog, Limit[':'], :tip_simplu, Limit[';'], :bloc, Limit[';']]],
    :declar_procedura =>
        [[Keyword.procedure, :antet_subprog, Limit[';'], :bloc, Limit[';']]],
    :antet_subprog =>
        [[Identifier, :param_form]],
    :param_form =>
        [[Operator['('], :lista_param_form, Operator[')']],
         [:epsilon]],
    :lista_param_form =>
        [[:declar_par],
         [:lista_param_form, Limit[';'], :declar_par]],
    :declar_par =>
        [[:decl_simpla],
         [Keyword.var, :decl_simpla]],
    :expresie_statica =>
        [[:termen_static],
         [:expresie_statica, :op_ad, :termen_static]],
    :termen_static =>
        [[:factor_static],
         [:termen_static, :op_mul, :factor_static]],
    :factor_static =>
        [[Identifier],
         [:constanta],
         [Operator['('],:expresie_statica,Operator[']']]],
    :op_ad =>
        [[Operator['+'],
         [Operator['-']]]],
    :op_mul =>
       [[Operator['*']],
        [Operator['/']],
        [Keyword.div],
        [Keyword.mod]],
    :constanta =>
        [[Numeric],
         [String] ],
    :instr_comp =>
        [[Keyword.begin,  :lista_instr, Keyword.end],
         [Keyword.begin,  :lista_instr,Limit[';'], Keyword.end]],
    :lista_instr =>
        [[:instr],
         [:lista_instr, Limit[';'], :instr]],
    :instr =>
        [[:instr_atrib],
         [:instr_if],
         [:instr_while],
         [:instr_repeat],
         [:instr_for],
         [:instr_case],
         [:instr_comp],
         [:instr_read],
         [:instr_print],
         [:apel_proc]],
    :instr_atrib =>
         [[:variabila, Operator[':='], :expresie]],
    :variabila =>
         [[Identifier, Operator['['], :expresie, Operator[']']],
          [Identifier, Operator['.'], Identifier],
          [Identifier]],
    :expresie =>
         [[:expresie, :op_ad, :termen],
          [:termen]],
    :termen =>
         [[:termen, :op_mul, :factor],
          [:factor]],
    :factor =>
         [[Identifier],
         [:constanta],
         [Operator['('], :expresie, Operator[')']],
         [Identifier, Operator['('], :lista_expresii, Operator[')']],
         [Identifier, Operator['['], :expresie, Operator[']']],
         [Identifier, Limit['.'], Identifier]],
    :lista_expresii =>
         [[:expresie],
         [:lista_expresii, :expresie]],
    :instr_if =>
          [[Keyword.if, :conditie, Keyword.then, :instr_ramura_else]],
    :ramura_else =>
          [[Keyword.else, :instr],
          [:epsilon]],
    :conditie =>
          [[:expr_logica],
          [Keyword.not, :expr_logica]],
    :expr_logica =>
          [[:expr_rel],
          [:expr_logica, :op_log, :expr_rel]],
    :op_log =>
          [[Keyword.and],
          [Keyword.or]],
    :expr_rel =>
          [[:expresie, :op_rel, :expresie],
          [Operator['('], :expresie, Operator[')']]],
    :op_rel =>
          [[Operator['<']],
           [Operator['>']],
           [Operator['<=']],
           [Operator['>=']],
           [Operator['=']],
           [Operator['<>']]],
    :instr_while =>
          [[Keyword.while, :conditie, Keyword.do, :instr]],
    :instr_repeat =>
          [[Keyword.repeat, :instr, Keyword.until, :conditie]],
    :instr_for =>
          [[Keyword.for, :variabila, Operator[':='], :expresie, :sens, :expresie, :pas, Keyword.do, :instr]],
    :sens =>
          [[Keyword.to],
          [Keyword.downto]],
    :pas =>
          [[Keyword.step, :expresie],
          [:epsilon]],
    :instr_case =>
          [[Keyword.case, :expresie, Keyword.of, :lista_altern, Keyword.end]],
    }
    remove_left_recursion(@non_terminals)
    @non_terminals    
  end

  def remove_left_recursion(nts)
    keys = nts.keys
    keys.each_with_index do |key, i|
      (0...i).each do |j|
        new_i = []
        nts[keys[i]].each do |d|
          if(d[0] == keys[j])
            d.shift
            nts[keys[j]].each do |jd|
              new_i << jd + d
            end
          else
            new_i << d
          end
        end
        new_key, new_arr = remove_direct_left_recursion(keys[i], new_i)
        nts[keys[i]] = new_i
        nts[new_key] = new_arr
      end
    end
    nts
  end
  def remove_direct_left_recursion(key, arr)
    if arr.find { |d| d[0] == key }
      betas = arr.find_all {|d| d[0] != key}
      alphas = arr.find_all {|d| d[0] == key}
      alphas.each {|d| d.shift }      
      arr.clear
      new_key = (key.to_s + '_rest').intern
      betas.each do |d|
        arr << d + [new_key]
      end
      new_arr = [:epsilon]
      alphas.each do |d|
        new_arr << d + [new_key, key]
      end
      return new_key, new_arr
    else
      return nil
    end
  end
end
