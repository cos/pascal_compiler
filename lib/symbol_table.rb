# To change this template, choose Tools | Templates
# and open the template in the editor.

class SymbolTable
  def initialize
    @a = [{}]
  end
  attr_accessor :a
  def [](ident)
    (a.length-1..0).each do |level|
      return a[level][ident] if a[level][ident]
    end
  end
  def <<(symbol)
    raise NameError.new('Symbol already exists', symbol[:name]) if a.last[symbol[:name]]
    a.last[symbol[:name]] = symbol
  end
end