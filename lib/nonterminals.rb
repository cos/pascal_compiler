require 'atoms'

module Nonterminals
  include Atom

  def program_sursa
    i [Keyword.program, Identifier, Limit[';'], :bloc, Limit['.']]
  end
  def bloc
    i [:sectiune_const, :sectiune_var, :sectiune_decl_subprog, :instr_comp]
  end
  def sectiune_const
    opt [Keyword.const , :lista_decl_const]
  end
  def lista_decl_const
    i :declar_const
    several :declar_const
  end
  def declar_const
    ident = i Identifier    
    i Operator['=']
    tv = i(:expresie_statica)
    i Limit[';']
    st << {:name => ident.name, :type => tv[0], :value => tv[1]}
  end
  def sectiune_var
    several :declar_var
  end  
  def sectiune_decl_subprog
    several :decl_subprog
  end  
  def decl_subprog
    one_of :declar_functie, :declar_procedura
  end
  def declar_var
    i [:lista_id, Limit[':'], :tip, Limit[';']]
  end
  def lista_id
    i Identifier
    several Identifier
  end
  def tip
    one_of :tip_simplu, :tip_tablou, :tip_struct
  end
  def tip_simplu
    one_of Keyword.integer, Keyword.real, Keyword.char, Keyword.string
  end
  def tip_tablou
    i [Keyword.array, Operator['['], :expresie_statica, Operator['.'], Operator['.'], :expresie_statica, Operator[']'], Keyword.of, :tip_simplu]
  end
  def tip_struct
    i [Keyword.record, :lista_camp, Keyword.end]
  end
  def lista_camp
    i :decl_simpla
    several [Limit[';'],:decl_simpla]
  end
  def decl_simpla
    i [:lista_id, Limit[':'], :tip_simplu]
  end
  def declar_functie
    i [Keyword.function, :antet_subprog, Limit[':'], :tip_simplu, Limit[';'], :bloc, Limit[';']]
  end
  def declar_procedura
    i [Keyword.procedure, :antet_subprog, Limit[';'], :bloc, Limit[';']]
  end
  def antet_subprog
    i [Identifier, :param_form]
  end
  def param_form
    opt [Operator['('], :lista_param_form, Operator[')']]
  end
  def lista_param_form
    i :declar_par
    several [Limit[';'],:declar_par]
  end
  def declar_par
    one_of :decl_simpla,
           [Keyword.var, :decl_simpla]
  end
  def expresie_statica
    i :termen_static
    several [:op_ad, :termen_static]
  end
  def termen_static
    i :factor_static
    several [:op_mul, :factor_static]
  end
  def factor_static    
    one_of Identifier, :constanta, [Operator['('],:expresie_statica,Operator[']']]
  end
  def op_ad
    one_of Operator['+'], Operator['-']
  end
  def op_mul
    one_of Operator['*'],Operator['/'],Keyword.div,Keyword.mod
  end
  def constanta
    one_of Numeric, String
  end
  def instr_comp
    i [Keyword.begin, :lista_instr]    
    opt Limit[';']
    i Keyword.end
  end
  def lista_instr
    i :instr
    several [Limit[';'], :instr]
  end
  def instr
    one_of :instr_atrib, :instr_if, :instr_while, :instr_repeat, :instr_for, :instr_case, :instr_comp
  end
  def instr_atrib
    i [:variabila, Operator[':='], :expresie]
  end
  def variabila
    one_of [Identifier, Operator['['], :expresie, Operator[']']],
           [Identifier,Operator['.'], Identifier],
           Identifier
  end
  def expresie
    i :termen
    several [:op_ad, :termen]
  end
  def termen
    i :factor
    several [:op_mul, :factor]
  end
  def factor
    one_of  :constanta,
            [Operator['('], :expresie, Operator[')']],
            [Identifier, Operator['('], :lista_expresii, Operator[')']],
            [Identifier, Operator['['], :expresie, Operator[']']],
            [Identifier, Limit['.'], Identifier],
            Identifier
  end
  def lista_expresii
    i :expresie
    several :expresie
  end
  def instr_if
    i [Keyword.if, :conditie, Keyword.then, :instr_ramura_else]
  end
  def ramura_else
    opt [Keyword.else, :instr]
  end
  def conditie
    opt Keyword.not
    i :expr_logica
  end
  def expr_logica
    i :expr_rel
    opt [:op_log, :expr_logica]
  end
  def op_log
    one_of Keyword.and, Keyword.or
  end
  def expr_rel
    one_of [:expresie, :op_rel, :expresie],
           [Operator['('], :expresie, Operator[')']]
  end
  def op_rel
    one_of Operator['<'], Operator['>'], Operator['<='], Operator['>='], Operator['='], Operator['<>']
  end
  def instr_while
    i [Keyword.while, :conditie, Keyword.do, :instr]
  end
  def instr_repeat
    i [Keyword.repeat, :instr, Keyword.until, :conditie]
  end
  def instr_for
    i [Keyword.for, :variabila, Operator[':='], :expresie, :sens, :expresie, :pas, Keyword.do, :instr]
  end
  def sens
    one_of Keyword.to, Keyword.downto
  end
  def pas
    opt [Keyword.step, :expresie]
  end
  def instr_case
    i [Keyword.case, :expresie, Keyword.of, :lista_altern, Keyword.end]
  end
end