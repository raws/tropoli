# Convenience methods for testing object emptiness. Stolen from Active Support.
# See https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/object/blank.rb.

class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
  
  def present?
    !blank?
  end
  
  def presence
    self if present?
  end
end

class NilClass
  def blank?
    true
  end
end

class FalseClass
  def blank?
    true
  end
end

class TrueClass
  def blank?
    false
  end
end

class Array
  alias_method :blank?, :empty?
end

class Hash
  alias_method :blank?, :empty?
end

class String
  def blank?
    self !~ /\S/
  end
end

class Numeric
  def blank?
    false
  end
end
