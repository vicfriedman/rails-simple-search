class Search

  def self.for(keyword)
    words = Word.all
    found_words = []
    words.each do |word|
      if word.name.include?(keyword)
        found_words << word
      end
    end
    found_words
  end

end
