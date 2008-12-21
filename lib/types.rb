# This contains the types that can be used in the virtual machine code

# Numeric

class StackAddress
  include Comparable
  def initialize(no)
    @no = no.to_int
  end
  attr_accessor :no
  def +(value)
    StackAddres.new(@no+value)
  end
  def to_int
    @no
  end
  def to_s
    'SA#'+@no.to_s
  end
  def <=>(another)
    @no <=> another.to_int
  end
end