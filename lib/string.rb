class String
  def quoted?
    (self =~ /^".*"$/) == 0
  end
  def quoted
    raise "#{self} is already quoted." if quoted?
    "\"#{self}\""
  end
end
