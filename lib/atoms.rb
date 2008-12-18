module Atom
  class Space
    def initialize(no_spaces = 1)
      @no_spaces = no_spaces
    end
    attr_reader :no_spaces
    def ==(another)
      another.is_a?(Space) && @no_spaces == another.no_spaces
    end
  end

  class NewLine
    attr_reader :line_no
    def initialize(no)
      @line_no = no
    end
    def ==(other)
      other.is_a?(NewLine)
    end
  end

  class IntegerWithBase
    def initialize(no, base)
      @no = no
      @base = base
    end
    attr_accessor :no, :base
    def ==(other)
      other.is_a?(IntegerWithBase) && @no == other.no && @base == other.base
    end
  end

  class Identifier
    def initialize(name)
      @name = name
    end
    attr_reader :name
    def ==(other)
      other.is_a?(Identifier) && @name==other.name
    end
    def to_s
      'Identifier: '+name
    end
  end

  class Comment
    def initialize(text)
      @text = text
    end
    attr_reader :text
    def ==(other)
      other.is_a?(Comment) && @text==other.text
    end
  end

  class Keyword    
    @@keywords = %w[string step to record array and begin case char const div do downto else end for function if integer mod not of or procedure program real repeat then until var while]
    def self.keywords
      @@keywords
    end
    def initialize(name)
      @name = name
    end
    attr_reader :name
    def ==(other)
      other.is_a?(Keyword) && @name==other.name
    end
    def to_s
      'Keyword: '+@name
    end
    def self.method_missing(method)
      if @@keywords.include? method.to_s
        Keyword.new(method.to_s)
      else
        throw 'Method not found: '+method.to_s
      end
    end
  end
  
  class Character
    def initialize(char)
      if(char.is_a? Numeric)
        @byte = char
      else
        @byte = char.to_s[0]
      end
    end
    def value
      @byte.chr
    end
    def ==(other)
      other.is_a?(Character) && other.value == value
    end
  end

  class Limit
    def initialize(symbol)
      @symbol = symbol
    end
    def self.[](string)
      Limit.new(string)
    end
    attr_reader :symbol
    def ==(other)
      other.is_a?(Limit) && other.symbol == symbol
    end

    def to_s
      'Limit: '+symbol
    end
  end

  class Operator
    def initialize(symbol)
      @symbol = symbol
    end
    attr_reader :symbol
    def ==(other)
      other.is_a?(Operator) && other.symbol == symbol
    end
    def self.[](string)
      Operator.new(string)
    end
    def to_s
      'Operator: '+symbol
    end
  end
end