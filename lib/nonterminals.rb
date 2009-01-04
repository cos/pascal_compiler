require 'atoms'

module Nonterminals
  include Atom

  def program_sursa
    x = gi
    i [Keyword.program, Identifier, Limit[';'], :bloc, Limit['.']]
    gi x, :rbm, st.l[0].length, 1
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
    a = i [Identifier, Operator['='], :expresie_statica, Limit[';']]
    st << ({
        :name => a[0].name,
        :type => (a[2].is_a?(Float) ? :float : :integer),
        :value => a[2],
        :class => :constant
      })
  end
  
  def sectiune_var
    opt [Keyword.var, :lista_decl_var]
  end
  def lista_decl_var
    i :declar_var
    several :declar_var
  end
  def sectiune_decl_subprog
    several :decl_subprog
  end  
  def decl_subprog
    one_of :declar_functie, :declar_procedura
  end
  def declar_var
    a = i [:lista_id, Limit[':'], :tip, Limit[';']]
    a[0].each do |id|
      st << ({
          :name => id.name,
          :type => a[2].name.intern,
          :class => :variable
        })
    end
  end
  def lista_id
    [i(Identifier)] + several([Limit[','],Identifier]).collect(){|i| i[1]}
  end
  def tip
    one_of :tip_simplu, :tip_tablou, :tip_struct
  end
  def tip_simplu
    one_of Keyword.integer, Keyword.real, Keyword.char, Keyword.string
  end

  # XXX not tested
  def tip_tablou
    i [Keyword.array, Operator['['], :expresie_statica, Operator['.'], Operator['.'], :expresie_statica, Operator[']'], Keyword.of, :tip_simplu]
  end

  # XXX not tested
  def tip_struct
    i [Keyword.record, :lista_camp, Keyword.end]
  end
  def lista_camp
    i :decl_simpla
    several [Limit[';'],:decl_simpla]
  end
  def decl_simpla
    a = i [:lista_id, Limit[':'], :tip_simplu]
    a[0].collect do |i|
      {
        :name => i.name,
        :type => a[2].name.intern
      }
    end
  end
  def declar_functie    
    a = i [Keyword.function, :antet_subprog, Limit[':'], :tip_simplu, Limit[';']]
    st << ({
        :name => a[1][:name].name,
        :type => a[3].name.intern,
        :class => :function,
        :rel_address => -1
      })
    procedure_function_common_block(a)
  end
  def declar_procedura
    a = i [Keyword.procedure, :antet_subprog, Limit[';']]
    st << ({
        :name => a[1][:name].name,
        :class => :function,
      })
    procedure_function_common_block(a)
  end
  
  def procedure_function_common_block(a)    
    st.level_up
    a[1][:params].each do |par|
      st << par
    end
    i [:bloc, Limit[';']]
    st.level_down
  end

  def antet_subprog
    {:name => i(Identifier), :params => i(:param_form) }
  end
  def param_form
    (opt [Operator['('], :lista_param_form, Operator[')']])[1] rescue []
  end
  def lista_param_form
    several([Limit[';'],:declar_par]).inject(i(:declar_par)){|all, i| all + i[1]}
  end
  def declar_par
    a = one_of :decl_simpla, [Keyword.var, :decl_simpla]
    clas = 
        if(a[0] == Keyword.var)
          a = a[1]
          :address_param
        else
          :value_param
        end
    a.each do |i|
      i[:class] = clas
    end
    a
  end
  def expresie_statica
    rez = i(:termen_static)
    several([:op_ad, :termen_static]).each do |a|
      if a[0] == Operator['+']
        rez += a[1]
      else
        rez -= a[1]
      end
    end
    rez
  end
  def termen_static
    rez = i :factor_static
    several([:op_mul, :factor_static]).each do |a|
      if(a[0] == Operator['*'])
        rez *= a[1]
      else
        rez /= a[1]
      end
    end
    rez
  end
  def factor_static
    a = one_of Identifier, :constanta, [Operator['('],:expresie_statica,Operator[')']]
    if(a.is_a? Identifier)
      st[a][:value]
    elsif a.is_a? Array
      a[1]
    else
      a
    end
  end
  def op_ad
    one_of Operator['+'], Operator['-']
  end
  def op_mul
    one_of Operator['*'],Operator['/'],Keyword.div,Keyword.mod
  end
  def constanta
    a = one_of [Operator['-'], Numeric],[Operator['+'], Numeric], Numeric, String
    if a.is_a? Array
      val = a[1]
      val = -val if a[0] == Operator['-']
      a = val
    end
    g :lodi, a
    a
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
    a = i [:variabila, Operator[':='], :expresie]
    correct_type([a[0],a[2]])
    g :sto
  end
  def variabila
    a = one_of [Identifier, Operator['['], :expresie, Operator[']']],
      [Identifier,Operator['.'], Identifier],
      Identifier

    if(a.is_a? Identifier)
      var = st[a]
      if(var[:class] == :function)
        raise type_error("function", "procedure") if var[:type].nil?
        g :loda, st.level, var[:rel_address]
      else
        g :loda, var[:level], var[:rel_address]
      end
      var[:type]
    else
      raise 'Not implemented yet'
    end
  end
  def expresie    
    correct_type([i(:termen)]+ several([:op_ad, :termen]).collect{|i| i[1]})
  end
  def termen
    correct_type([i(:factor)]+ several([:op_mul, :factor]).collect{|i| i[1]})
  end
  def factor
    a = one_of :constanta,                                                # ok
      [Operator['('], :expresie, Operator[')']],
      [Identifier, Operator['('], :lista_expresii, Operator[')']],
      [Identifier, Operator['['], :expresie, Operator[']']],
      [Identifier, Limit['.'], Identifier],
      Identifier

    a = a[1] if(a.is_a?(Array) && a.length == 3)    
    
    if a.is_a? Symbol
      a
    elsif a.is_a? Identifier
      case st[a][:class]
      when :constant:
        g :lodi, st[a][:value]
      when :variable:
        g :lod, st[a][:level], st[a][:rel_address]
      when :address_param:
        g :lod, st[a][:level], st[a][:rel_address]
      when :value_param:
        g :lod, st[a][:level], st[a][:rel_address]
      when :function:
        raise 'Todo'
      else
        raise 'Somethind else'+st[a].inspect+'||'+a.inspect.to_s
      end
      st[a][:type]
    elsif a.is_a? String
      :string
    elsif a.is_a? Float
      :real
    elsif a.is_a? Integer
      :integer
    else
      raise 'Some kind of error'
    end
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