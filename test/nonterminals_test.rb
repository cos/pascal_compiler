$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'nonterminals'

class NonterminalsTest < Test::Unit::TestCase
  def setup
    @tc =
      Class.new do
        include Nonterminals
      end.new
  end
  def test_remove_direct_left_recursion
    arr = [[:A, :a1], [:A, :a2, :a3], [:b1], [:b2, :b3]]
    new_key, new_arr = @tc.remove_direct_left_recursion(:A,
      arr
    )
    assert_equal :A_rest, new_key
    assert_equal [[:b1, :A_rest], [:b2, :b3, :A_rest]], arr
    assert_equal [:epsilon, [:a1, :A_rest, :A], [:a2, :a3, :A_rest, :A]], new_arr
  end

#  def test_remove_left_recursion
#    arr = {
#      :E => [[:E, :plus, :T], [:T]],
#      :T => [[:T, :or, :F], [:F]],
#      :F => [[:op, :E, :cp], [:int]]
#    }
#    arr = @tc.remove_left_recursion(arr)
#    assert_equal({
#          :F=>		[[:op, :E, :cp], [:int]],
#          :T_rest=>	[:epsilon, [:or, :F, :T_rest, :T]],
#          :E=>		[[:T, :E_rest]],
#          nil=>nil,
#          :T=>		[[:op, :E, :cp, :T_rest], [:int, :T_rest]],
#          :E_rest=>	[:epsilon, [:plus, :T, :E_rest, :E]]
#      }, arr)
#  end
end
