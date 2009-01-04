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

    @vm_code = []
  end

  attr_accessor :st
  attr_accessor :vm_code

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
      cur_code_length = self.vm_code.length
      i(arg||exe)
    rescue SyntaxError
      @current_atom_index = cur_index
      self.vm_code = self.vm_code[0...cur_code_length]
      nil
    end
  end

  # 0 or more
  def several(what)
    begin
      a = []
      while true
        cur_index = @current_atom_index
        cur_code_length = self.vm_code.length
        a << i(what)
      end
    rescue SyntaxError
      self.vm_code = self.vm_code[0...cur_code_length]
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
      expected = [expected] unless expected.is_a? Array
      super('Expected type '+(expected*' or ')+ ', was '+actual+' on line '+line.to_s)
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

  rescue SymbolTable::IdentifierError
    $!.line = @line_no    
    raise $!
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

  # generate code instruction
  def g(*args)
    self.vm_code += args
  end

  # get the next code index or insert before the given index
  def gi(*args)
    if(args.empty?)
      self.vm_code.length
    else
      self.vm_code.insert(args.shift, *args)
    end
  end

  def correct_type(array)
    current = nil
    (array).each do |t|
      current = t if current.nil?
      case current
        when :string:
            type_error(:string, t) if t != :string
        when :integer:
            type_error([:real, :string], :string) if t == :string
            current = :real if t == :real
        when :real:
            type_error([:real, :string], :string) if t == :string
      end
    end
    current
  end
end