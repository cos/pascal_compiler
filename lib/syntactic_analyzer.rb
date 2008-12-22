require 'nonterminals'
require 'symbol_table'

class SyntacticAnalyzer
  include Nonterminals
  
  def initialize(atom_resource)
    @atoms = atom_resource
    @atoms_errors = {}
    @line_no = 1
    @non_terminals_stack = []
    @st = SymbolTable.new
    @current_atom_index = 0
  end

  attr_accessor :st

  def self.parse(atom_resource)
    SyntacticAnalyzer.new(atom_resource).analize
  end

  def analize
    @current_atom_index = 0
    begin
      program_sursa
    rescue SyntaxError
      s = deepest_errors.inject('') {|s,e| s+= ' or ' +e.expected}
      raise 'Expected '+s+', found '+deepest_errors[0].actual+" on line "+deepest_errors[0].line.to_s
    end
  end

  def a
    @atoms[@current_atom_index]
  end
  def n
    @current_atom_index+=1    
    if a.is_a? NewLine
      @line_no = a.line_no; n
    else
      a
    end
  end
  
  def opt(arg,&exe)
    begin
      cur_index = @current_atom_index
      i(arg||exe)
    rescue SyntaxError
      @current_atom_index = cur_index
      nil
    end
  end

  # 0 or more
  def several(what)
    begin
      a = []
      while true
        cur_index = @current_atom_index
        a << i(what)
      end
    rescue SyntaxError
      @current_atom_index = cur_index
      a
    end
  end

  class SyntaxError < Exception
    def initialize(expected, actual, line)
      super('Expected '+expected+ ' was '+actual+' on line '+line)
      @expected, @actual, @line = expected, actual, line
    end
    attr_reader :expected, :actual, :line
  end

  class TypeError < Exception
    def initialize(expected, actual, line)
      super('Expected type '+(expected*' or ')+ ', was '+actual+' on line '+line)
      @expected, @actual, @line = expected, actual, line
    end
    attr_reader :expected, :actual, :line
  end
  
  # internal use
  def error(expected, actual, line)
    @atoms_errors[@current_atom_index] = [] unless @atoms_errors[@current_atom_index]
    exception = SyntaxError.new(expected, actual, line)
    @atoms_errors[@current_atom_index] << exception
    raise exception
  end

  def type_error(expected, actual)
    raise TypeError.new(expected,actual,@line_no)
  end

  def deepest_errors
    @atoms_errors[@atoms_errors.keys.max]
  end

  def require(expected)
    right_class = begin
                      a.is_a? expected
                    rescue
                      false
                    end
    error(expected.to_s,a.to_s,@line_no.to_s) unless a == expected || right_class
  end

  
  def i(v)
    if v.is_a? Symbol
      method(v).call
    elsif v.is_a? Array
      v.collect {|vi| i(vi)}
    elsif v.is_a? Class
      require v; val = a; n; val
    elsif v.is_a? Proc
      v.call
    else
      require v; val = a; n; val
    end
  end

  def one_of(*variants)
    return if variants.empty?
    err = nil
    variants.each do |v|
      begin
        cur_index = @current_atom_index
        a = i(v)
      rescue SyntaxError => e
        err = e
        @current_atom_index = cur_index
      else
        return a
      end
    end
    raise err
  end


end