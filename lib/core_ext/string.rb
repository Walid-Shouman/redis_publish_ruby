# Enable for debugging
# puts "loaded #{__FILE__}"

class String
  def to_boolean
      self == 'true'
  end
end
