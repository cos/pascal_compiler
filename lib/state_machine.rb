require 'atoms'

class StateMachine
  ELSE = /./m
  @@transitions = {
    :start =>                     [{
        /\d/ => :integer           },{
        /(\+|-)/ => :additive            },{
        /(\*|\/)/ => :multiplicative      },{
        /(\(|\))/ => :round_bracket           },{
        /(\[|\])/ => :squere_bracket          },{
        /</ => :lt                        },{
        />/ => :gt                        },{
        /=/ => :equal                        },{        
        / / => :space             },{
        /\n/ => :new_line         },{
        /"/ => :in_string         },{
        /\{/ => :in_comment         },{
        /'/ => :start_char         },{
        /:/ => :colon              },{
        /(,|;|\.)/ => :limit           },{
        /[a-zA-Z_]/ => :identifier },{
        ELSE => :error            }],

    :integer =>                             [{
        /\d/ => :integer                    },{
        /\./ => :float_on_dot               },{
        /@/ => :integer_with_base_on_at     },{
        ELSE => :done                       }],

    :integer_with_base_on_at =>             [{
        /(\d|[A-Za-z])/ => :integer_with_base          },{
        ELSE => :error                      }],

    :integer_with_base =>                   [{
        /(\d|[A-Za-z])/ => :integer_with_base          },{
        ELSE => :done                       }],


    :float_on_dot => [{
        /\d/ => :float_simple   },{
        ELSE => :error}]   ,

    :float_simple => [{
        /\d/ => :float_simple   },{
        /E|e/ => :float_on_e   },{
        ELSE => :done}]  ,

    :float_on_e => [{
        /\+/ => :float_on_base_sign   },{
        /-/ => :float_on_base_sign   },{
        /\d/ => :float_scientific   },{
        ELSE => :error }]  ,

    :float_on_base_sign => [{
        /\d/ => :float_scientific, },{
        ELSE => :error}],

    :float_scientific => [{
        /\d/ => :float_scientific   },{
        ELSE => :done  }]  ,

    :space => [{
      / / => :space   },{
      ELSE => :done }]  ,

    :new_line => [{
      ELSE => :done }],

    :identifier => [{
        /[a-zA-Z_]/ => :identifier   },{
        ELSE => :done }],

    :in_string => [{
        /(\w|\s)/ => :in_string },{
        /"/ => :string },{
        ELSE => :error
      }],
    :string => [{
        ELSE => :done
      }],

    :in_comment => [{
        /[a-zA-Z]/ => :in_comment },{
        /\}/ => :comment },{
        ELSE => :error
      }],
    :comment => [{
        ELSE => :done
      }],

    :start_char => [{
        /[a-zA-Z]/ => :in_char },{
        ELSE => :error
      }],

    :in_char => [{
        /'/ => :char },{
        ELSE => :error
      }],

    :char => [{
        ELSE => :done
      }],

    :limit => [{    
        ELSE => :done
      }],

    :colon => [{
        /=/ => :attribution },{
        ELSE => :done
      }],

    :additive => [{  
        /\d/ => :integer },{
        ELSE => :done  }],
    :multiplicative => [{  ELSE => :done  }],
    :round_bracket => [{  ELSE => :done  }],
    :squere_bracket => [{  ELSE => :done  }],
    :lt => [{  
        />/ => :different },{
        /=/ => :lt_or_equal },{
        ELSE => :done  }],
    :lt_or_equal => [{  ELSE => :done  }],
    :gt => [{  
        /=/ => :gt_or_equal },{
        ELSE => :done  }],
    :gt_or_equal => [{  ELSE => :done  }],
    :equal => [{  ELSE => :done  }],
    :different => [{  ELSE => :done  }],
    :attribution => [{  ELSE => :done  }],
}

  @@keywords = Atom::Keyword.keywords

  attr_accessor :state
  attr_reader :log

  def initialize(current_state = :start, log = nil)
    @log = log
    @state = current_state
    @token = ""
    @line_number = 1
    @line_position = 0

    @state_atoms = {
      :integer => lambda {|s|        
        log 'Integer overflow' if(s.to_i > 32000)
        s.to_i
      },
      :float_simple => lambda {|s| s.to_f},
      :float_scientific => lambda {|s| s.to_f},
      :space => lambda {|s| Atom::Space.new(s.length) },
      :new_line => lambda {|s| Atom::NewLine.new(@line_number)},
      :integer_with_base => lambda {|s| Atom::IntegerWithBase.new(s.split('@')[0].to_i, s.split('@')[1].to_i)},
      :identifier => lambda {|s|
        if(@@keywords.include?(s))
          Atom::Keyword.new(s)
        else
          Atom::Identifier.new(s)
        end },

      :string => lambda {|s| s.delete '"'},
      :comment => lambda {|s| Atom::Comment.new(s.delete('{}'))},
      :char => lambda {|s| Atom::Character.new(s.delete("'"))},
      :limit => lambda {|s| Atom::Limit.new(s)},
      :colon => lambda {|s| Atom::Limit.new(s)},
      :additive => lambda {|s| Atom::Operator.new(s)},
      :multiplicative => lambda {|s| Atom::Operator.new(s)},
      :round_bracket => lambda {|s| Atom::Operator.new(s)},
      :squere_bracket => lambda {|s| Atom::Operator.new(s)},
      :lt => lambda {|s| Atom::Operator.new(s)},
      :lt_or_equal => lambda {|s| Atom::Operator.new(s)},
      :gt => lambda {|s| Atom::Operator.new(s)},
      :gt_or_equal => lambda {|s| Atom::Operator.new(s)},
      :equal => lambda {|s| Atom::Operator.new(s)},
      :different => lambda {|s| Atom::Operator.new(s)},
      :attribution => lambda {|s| Atom::Operator.new(s)},
    }
  end

  def put(c)
    @line_position += 1
    next_state = next_state(@state, c)   
    if(next_state == :done)            
      atom = atom_for(@state,@token)
      atom = nil if atom.is_a? Atom::Space
      next_state = next_state(:start, c)
      @token = ""
    end
    
    @token << c

    if(next_state == :new_line)
      @line_number+=1      
      @line_position = 0
    end

    if(next_state == :error)
       log 'Syntax error in '+@state.to_s
    end
    
    @state = next_state   
    return atom
  end

  private
  def next_state(state, c)
    next_state = nil
    throw "Couldn't find transitions entry for "+state.to_s unless @@transitions[state]
    @@transitions[state].each do |rel|
      reg = rel.keys[0]
      if c =~ reg
        next_state = rel[reg]
        break
      end
    end
    throw "Couldn't find next state after :"+state.to_s unless next_state
    next_state    
  end

  def atom_for(state, str)
    throw 'Atom for state :'+state.to_s+' not found' unless @state_atoms[state]    
    @state_atoms[state].call(str)
  end

  class LexicalError < Exception
    def initialize(what)
      super(what)
    end
  end

  def log(what)
    what = @line_number.to_s+':'+@line_position.to_s+' '+what+'#'+@token+'#'
    if(@log)
      @log << what
    else
      raise LexicalError.new(what)
    end
  end
end