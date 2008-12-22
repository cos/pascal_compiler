$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'lexical_analyzer'

class LexicalAnalyzerTest < Test::Unit::TestCase
  include Atom

  def test_simple
    assert_equal [45], LexicalAnalyzer.parse('45 ')
  end
  def test_two
    assert_equal [45,56], LexicalAnalyzer.parse('45 56 ')
  end
  def test_with_plus
    assert_equal [45,56,Operator['+'],3434], LexicalAnalyzer.parse('45 56 +3434 ')
  end

  def test_plus
    assert_equal [5, Atom::Operator['+'], 7], LexicalAnalyzer.parse('5+7 ')
  end

  def test_with_minus
    assert_equal [45,Operator['-'],56], LexicalAnalyzer.parse('45 -56 ')
  end
  def test_float_simple
    assert_equal [34.5], LexicalAnalyzer.parse('34.5 ')
  end
  def test_float_scientific
    assert_equal [34.5E4], LexicalAnalyzer.parse('34.5E4 ')
  end
  def test_float_scientific
    assert_equal [34.5E-4], LexicalAnalyzer.parse('34.5E-4 ')
  end
  def test_integer_with_base
    assert_equal [Atom::IntegerWithBase.new(23,45)], LexicalAnalyzer.parse('23@45 ')
  end
  def test_identifier
    assert_equal [Atom::Identifier.new('test')], LexicalAnalyzer.parse('test ')
  end
  def test_keyword
    assert_equal [Atom::Keyword.new('and')], LexicalAnalyzer.parse('and ')
  end
  def test_string
    assert_equal ['test'], LexicalAnalyzer.parse('"test" ')
  end
  def test_char
    assert_equal [Atom::Character.new('c')], LexicalAnalyzer.parse("'c' ")
  end
  def test_comment
    assert_equal [Atom::Comment.new('test')], LexicalAnalyzer.parse('{test} ')
  end
  def test_limit
    assert_equal [Atom::Limit.new(';')], LexicalAnalyzer.parse('; ')
  end
  def test_lt
    assert_equal [Atom::Operator.new('<')], LexicalAnalyzer.parse('< ')
  end
  def test_lt_or_equal
    assert_equal [Atom::Operator.new('<=')], LexicalAnalyzer.parse('<= ')
  end
  def test_gt
    assert_equal [Atom::Operator.new('>')], LexicalAnalyzer.parse('> ')
  end
  def test_gt_or_equal
    assert_equal [Atom::Operator.new('>=')], LexicalAnalyzer.parse('>= ')
  end
  def test_equal
    assert_equal [Atom::Operator.new('=')], LexicalAnalyzer.parse('= ')
  end
  def test_different
    assert_equal [Atom::Operator.new('<>')], LexicalAnalyzer.parse('<> ')
  end
  def test_attribution
    assert_equal [Atom::Operator.new(':=')], LexicalAnalyzer.parse(':= ')
  end
  def test_int_overflow
    assert_raises(StateMachine::LexicalError) {
      LexicalAnalyzer.parse('235242534653453245 ')
    }
  end

  def test_line_numbers
    test = <<-TESTTEST
      i=bal
      i = VBAZA
      b = 5

      TESTTEST

    atoms = LexicalAnalyzer.parse(test)
    assert_equal 3, atoms.find_all {|a| a.is_a? Atom::NewLine}.length
  end


  def test_complicated
    test = <<-TESTTEST
        program bla;
        i=bal
        i = VBAZA
        while nivel <> BAZA[i].LEVEL do
        i = i - 1
        endwhile
        adr = BAZA[i].BLOC + adrel     //(**)
        while STIVA[adr].TIP_NOD = "adresa " do
        adr = STIVA[adr].INFO
        endwhile
        SP = SP + 1
        STIVA[SP] = STIVA[adr]
        NI = NI + 3
        TESTTEST
    
    LexicalAnalyzer.parse(test)
  end
end