# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'syntactic_analyzer'
require 'lexical_analyzer'

class SyntacticAnalyzerTest < Test::Unit::TestCase

#  def test_very_simple
#    SyntacticAnalyzer.parse(LexicalAnalyzer.parse('program test;begin end. '))
#  end
#
#  def test_a_bit_more_complex
#    SyntacticAnalyzer.parse(LexicalAnalyzer.parse('program test;const bla=bla;. '))
#  end
#
#  def test_constants
#    SyntacticAnalyzer.parse(LexicalAnalyzer.parse('program test;const bla=56;. '))
#  end

  def test_complex
    test = <<-TESTTEST
    program bla;
      const a=7;
      a:integer;
      begin
        a := 5;
      end.
    TESTTEST

    SyntacticAnalyzer.parse(LexicalAnalyzer.parse(test))
  end

  def test_complex1
    test = <<-TESTTEST
    program bla;
      const a=7;
      a:integer;

      procedure bla(b:integer);
      begin
        e:=b+b ;
      end

      begin
        a := 5;
      end.
    TESTTEST

    SyntacticAnalyzer.parse(LexicalAnalyzer.parse(test))
  end
end