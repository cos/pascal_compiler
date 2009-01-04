# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'symbol_table'

class SymbolTableTest < Test::Unit::TestCase
  def setup
    @st = SymbolTable.new
    @st.a = [{1=>1,2=>2,3=>3},{'bla' => {:name => 'bla'}}]
  end
  def test_add
    @st << {:name => 'tralala'}
    assert_equal({:name => 'tralala', :level => 1, :rel_address => 1}, @st.a[1]['tralala'])
  end
  def test_add_not_working
    assert_raise(NameError) do |i|
      @st << {:name => 'bla'}
    end
  end
end
