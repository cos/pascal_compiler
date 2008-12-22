# To change this template, choose Tools | Templates
# and open the template in the editor.

class SymbolTable
  def initialize
    @a = [{}]
  end
  attr_accessor :a
  def [](ident)
    ident = ident.name if ident.is_a? Identifier
    (a.length-1..0).each do |level|
      return a[level][ident] if a[level][ident]
    end
  end
  def <<(symbol)
    if a.last[symbol[:name]]
      raise NameError.new('Symbol already exists', symbol[:name])
    end
    a.last[symbol[:name]] = symbol
  end
  def level_up
    @a << {}
  end
  def level_down
    @a.pop
  end
end