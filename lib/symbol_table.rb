# To change this template, choose Tools | Templates
# and open the template in the editor.

class SymbolTable
  def initialize
    @a = [{}]
  end
  attr_accessor :a

  class IdentifierError < Exception
    def initialize(not_found, visible)      
      @found, @visible = not_found , visible      
    end
    def message
      'Couldn\'t find identifier '+@found+" on line "+ @line.to_s()+" \n Visible identifiers: "+@visible * ', '
    end
    attr_accessor :found, :line, :visible
  end

  # Find an identifier, raise error otherwise
  def [](ident)
    ident = ident.name if ident.method :name    
    (a.length-1).downto 0 do |level|
      return a[level][ident] if a[level][ident]
    end    
    raise IdentifierError.new(ident, visible)
  end

  def visible(level = nil)
    level = a.length - 1 unless level
    a[0..level].inject([]){|all, h| all += h.keys }
  end
  # Get the whole array. Can be used as: a[2][:bla] to find identifier :bla in level 2
  def l
    a
  end

  def level
    return a.length - 1
  end

  def <<(symbol)
    if a.last[symbol[:name]]
      raise NameError.new('Symbol already exists', symbol[:name])
    end
    symbol[:level] = level
    symbol[:rel_address] = symbol[:rel_address] || (a[level].length - (a[level].values.inject(0) { |count, item| item[:class]==:function&&item[:type] ? 1 : 0 }))
    a.last[symbol[:name]] = symbol
  end
  def level_up
    @a << {}
  end
  def level_down
    @a.pop
  end
end