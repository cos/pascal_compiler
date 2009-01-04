$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'lexical_analyzer'
require 'syntactic_analyzer'
require 'nonterminals'
require 'atoms'
require 'mocha'

class NonterminalsTest < Test::Unit::TestCase
  include Atom

  ST_CONST = {
            :name => 'abc',
            :type => :integer,
            :value => 5,
            :class => :constant
          }

  def setup
    @sa = SyntacticAnalyzer.new([])
    @sa.stubs(:n)
  end

  def test_sectiune_const
    set ''
    assert_nil @sa.sectiune_const
  end

  def test_sectiune_const1
    set 'const abc=-1+2*3;bc = 4+5.5;'
    @sa.st.expects(:<<).with(ST_CONST)
    @sa.st.expects(:<<).with({
            :name => 'bc',
            :type => :float,
            :value => 9.5,
            :class => :constant
          })
    @sa.sectiune_const
  end

  def test_sectiune_const2
    set 'const abc=-1+2*3;'
    @sa.st.expects(:<<).with(ST_CONST)
    @sa.sectiune_const
  end

  def var_expectation
    %w%a ab abc%.each do |id|
      @sa.st.expects(:<<).with({
              :name => id,
              :type => :integer,
              :class => :variable
            })
    end
  end

  def test_sectiune_var
   set 'var a,ab,abc: integer;'
    var_expectation
    @sa.sectiune_var
  end

  def test_declar_var
    set 'a,ab,abc: integer;'
    var_expectation
    @sa.declar_var
  end

  def test_declar_par
    set 'a,ab,abc: integer;'
    exp = %w%a ab abc%.collect do |id|
          {
              :name => id,
              :type => :integer,
              :class => :value_param
            }
    end
    assert_equal exp, @sa.declar_par
  end

  def test_lista_id
    set 'a,ab,abc'
    assert_equal ['a','ab','abc'].collect{|i| Identifier.new(i)}, @sa.lista_id
  end

  def test_tip_simplu
    set 'real'
    assert_equal Keyword.real, @sa.tip_simplu
  end

  def test_declar_const
    set 'abc=-1+2*3;'
    @sa.st.expects(:<<).with(ST_CONST)
    @sa.declar_const
  end

  def test_declar_functie
    set 'function bla(a: integer):real; begin a:=5 end;'
    @sa.st.expects(:<<).with(
        {
        :name => 'bla',
        :type => :real,
        :class => :function,
        :rel_address => -1
        })
    @sa.st.expects(:<<).with(
        {
        :name => 'a',
        :type => :integer,
        :class => :value_param
        })

    @sa.st.stubs(:[]).returns({})

    @sa.declar_functie
  end

  def test_declar_procedure
    set 'procedure bla(a: integer); begin a:=5 end;'

    @sa.st.expects(:<<).with(
        {
        :name => 'bla',        
        :class => :function
        })
    @sa.st.expects(:<<).with(
        {
        :name => 'a',
        :type => :integer,
        :class => :value_param
        })

    @sa.st.stubs(:[]).returns({})

    @sa.declar_procedura
  end

  def test_bloc
    set 'const a=5+8; var b:real; begin b:=9 end'
    @sa.bloc
  end


  def test_constanta
    @sa.stubs(:a).returns 5    
    assert_equal 5, @sa.constanta
    assert_code [:lodi, 5]
  end

  def test_expresie_statica
    set('5')
    assert_equal 5, @sa.expresie_statica
  end

  def test_expresie_statica1
    set('5*7')
    assert_equal 35, @sa.expresie_statica
  end

  def test_expresie_statica2
    set('5+7')
    assert_equal 12, @sa.expresie_statica
  end

  def test_expresie_statica3
    set('5+-3')
    assert_equal 2, @sa.expresie_statica
  end

  def test_expresie_statica4
    set('5*-3')
    assert_equal(-15, @sa.expresie_statica)
  end

  def test_expresie_statica5
    set('-5*(-3+7)')
    assert_equal(-20 , @sa.expresie_statica)
  end

  def test_termen_static1
    set('2*3')
    assert_equal 6, @sa.termen_static
  end

  def test_termen_static2
    set('2')
    assert_equal 2, @sa.termen_static
  end

  def test_termen_static3
    set('6/3*2')
    assert_equal 4, @sa.termen_static
  end

  def test_factor_static1
    @sa.stubs(:a).returns 5
    assert_equal 5, @sa.factor_static
  end

  def test_factor_static2
    @sa.stubs(:a).returns Identifier.new('bla')
    @sa.st.stubs(:[]).with(Identifier.new('bla')).returns({:value => 7})
    assert_equal 7, @sa.factor_static
  end

  def test_factor_static3
    set('(5)')
    assert_equal 5, @sa.factor_static
  end
  def test_factor_static4
    set('(5+7)')
    assert_equal 12, @sa.factor_static
  end

  def set(string)
    @sa = SyntacticAnalyzer.new(LexicalAnalyzer.parse(string+' '))
  end

  def test_factor1
    set '5'
    assert_equal :integer, @sa.factor
  end

  def test_factor2
    set '5.5'
    assert_equal :real, @sa.factor
  end

  def test_factor3
    set 'bla'
    @sa.st << {:name => "bla", :type => :real, :class => :variable}
    assert_equal :real, @sa.factor
  end

  def test_factor4
    set '(bla)'
    @sa.st << {:name => "bla", :type => :real, :class => :variable}
    assert_equal :real, @sa.factor
  end

  def test_program
    set('program bla; var a:integer; begin a:=5; end.')
    @sa.analize
    assert_code [:rbm, 1, 1]
  end

  def test_variabila1
    set('program bla; var a:integer; begin a:=5; end.')
    @sa.analize
    assert_code [:loda, 0, 0]
  end

  def test_variabila2
    set('program bla; var a:integer; begin b:=5; end.')
    assert_raise SymbolTable::IdentifierError do
      @sa.analize
    end
  end

  def test_instr_atrib
    set('program bla; var a:integer; begin a:=5; end.')
    @sa.analize
    assert_code [:loda, 0, 0, :lodi, 5, :sto]
  end

  def test_instr_atrib1
    set('program bla; var a:string; begin a:=5; end.')
    assert_raise TypeError do
      @sa.analize
    end
  end

  def test_instr_atrib2
    set('program bla; var a:real; begin a:=5; end.')
    @sa.analize
    assert_code [:loda, 0, 0, :lodi, 5, :sto]
  end

  def test_instr_atrib3
    set('program bla; var a:real; procedure bla(i:integer); begin i:=3; end; begin a:=5; end.')
    @sa.analize
    assert_code [:loda, 1, 0, :lodi, 3, :sto]
  end

  def test_instr_atrib3
    set('program bla; var a:real; procedure bla(i:integer); begin i:=a; end; begin a:=5; end.')
    @sa.analize
    assert_code [:loda, 1, 0, :lod, 0, 0, :sto]
  end

  def test_instr_atrib4
    set('program bla; var a:real; procedure bla(i:integer); begin bla:=a; end; begin a:=5; end.')

    assert_raise SyntacticAnalyzer::TypeError do
      @sa.analize
    end
  end

  def test_instr_atrib5
    set('program bla; var a:real; function bla(i:integer):real; begin bla:=i; end; begin a:=5; end.')
    @sa.analize
    assert_code [:loda, 1, -1, :lod, 1, 0, :sto]
  end

  def assert_code(arr)
    no = 0
    @sa.vm_code.each do |el|
      if no!=0 && el != arr[no]
        assert_equal arr.length, no, "Couldn find code sequence "+arr.inspect+" in "+@sa.vm_code.inspect
        return
      end
      no += 1 if el == arr[no]
    end
    assert_equal arr.length, no, "Couldn find code sequence "+arr.inspect+" in "+@sa.vm_code.inspect
  end
end
