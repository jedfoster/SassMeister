# A couple of additional Array methods.

# From: http://rubyquicktips.com/post/2625525454/random-array-item
class Array
  def random
    shuffle.first
  end

  def to_sentence
    length < 2 ? first.to_s : "#{self[0..-2] * ', '}, and #{last}"
  end
end