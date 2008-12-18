require 'nonterminals'

class SyntacticAnalyzer
  include Nonterminals

  def initialize(atom_resource)
    @atoms = atom_resource
    @atoms_errors = {}
    @line_no = 1
    @non_terminals_stack = []
  end

  def self.parse(atom_resource)
    SyntacticAnalyzer.new(atom_resource).analize
  end

  def analize
    @current_atom_index = -1
    begin      
      one_of(*non_terminals[:program_sursa])
    rescue SyntaxError
      s = ""
      deepest_errors.each {|e| s+= ' or ' +e.expected; puts "\n>>>>\n"+e.non_terminals_stack.join('->')}
      raise 'Expected '+s+', found '+deepest_errors[0].actual+" on line "+deepest_errors[0].line.to_s
    end
  end

  def a
    @atoms[@current_atom_index]
  end
  def n
    @current_atom_index+=1    
    if a.is_a? NewLine
      @line_no = a.line_no
      n
    else
      a
    end
  end

  def error(expected, actual, line)
    @atoms_errors[@current_atom_index] = [] unless @atoms_errors[@current_atom_index]
    exception = SyntaxError.new(expected, actual, line, @non_terminals_stack)
    @atoms_errors[@current_atom_index] << exception
    raise exception
  end

  def deepest_errors
    @atoms_errors[@atoms_errors.keys.max]
  end

  class SyntaxError < Exception
    def initialize(expected, actual, line, non_terminals_stack)
      super('Expected '+expected+ ' was '+actual+' on line '+line)
      @expected, @actual, @line, @non_terminals_stack = expected, actual, line, non_terminals_stack.dup
    end
    attr_reader :expected, :actual, :line, :non_terminals_stack
  end  

  # internal use
  def require(expected)
    right_class = begin
                    a.is_a? expected
                  rescue
                    false
                  end
     error(expected.to_s,a.to_s,@line_no.to_s) unless a == expected || right_class
  end

  def interpret(v)
    if v.is_a? Symbol
      return if v == :epsilon
      @non_terminals_stack.push(v)
      one_of(*non_terminals[v])
      @non_terminals_stack.pop
    elsif v.is_a? Array
      v.each {|vi| interpret(vi)}
    elsif v.is_a? Class
      n; require v
    elsif v.is_a? Proc
      v.call
    else
      n; require v
    end
  end

  def one_of(*variants)
    return if variants.empty?
    error = nil
    variants.each do |v|
      begin
        cur_index = @current_atom_index
        interpret(v)
      rescue SyntaxError => e
        error = e
        @current_atom_index = cur_index
      else
        return
      end
    end
    raise error
  end

#  def several_of(*variants)
#    at_least_one = false
#    variants.each do |v|
#      begin
#        cur_index = @current_atom_index
#        method(v).call
#      rescue(SyntaxError e)
#        if(at_least_one)
#          return
#        else
#          raise e
#        end
#      else
#        return
#      end
#    end
#  end
  
#  [:program_sursa, :bloc].each do |met|
#    alias_method(('nont_'+met.to_s).intern, met)
#    define_method(met) {
#      begin
#        curret_atom_index = @current_atom_index
#        self.method(('nont_'+met.to_s).intern).call
#      rescue(SyntaxError e)
#        @current_atom_index = current_atom_index
#        raise e
#      end
#    }
#  end
end