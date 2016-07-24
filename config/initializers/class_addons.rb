# Add a to_bool method on many class to ease conversion
module ToBoolean
  def to_bool
    return true if ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(self)
    return false
  end
end

class NilClass; include ToBoolean; end
class TrueClass; include ToBoolean; end
class FalseClass; include ToBoolean; end
class Numeric; include ToBoolean; end
class String; include ToBoolean; end


# Add to the String class a method to check if the String contains just an integer
class String
  def is_integer?
    self.to_i.to_s == self
  end
end
