require 'state_machine'

class LexicalAnalyzer
  def self.parse(text)
    @atoms = LexicalAnalyzer.new(text).generate_all_atoms    
    @atoms
  end

  def initialize(text)
    @text = text
    @current_text_index = 0

    @current_index = 0
    @atoms = []

    @sm = StateMachine.new(:start)
    @atoms << generate_atom
  end

  def generate_all_atoms
    while(a = generate_atom)
      @atoms << a
    end
    @atoms
  end

  def [](index)
    (@current_index...index).each do
      return nil if (a = generate_atom) == nil
      @atoms << a
    end
    @atoms[index]
  end

  private
  def generate_atom
    n = 0
    while true
      return nil unless @text[@current_text_index]
      c = @text[@current_text_index].chr
      @current_text_index+=1
      atom = @sm.put(c)
      return atom if atom
    end
    nil
  end
end