require 'benchmark'

class AnagramSearch
  def initialize(search_word:, source:)
    @search_word = search_word
    @source = source
  end

  def decremental
    search_word_size = search_word_chars.size

    @source.select do |line|
      word = line.strip

      next if word.size != search_word_size

      search_word_chars.all? { |c| word.sub!(c, '') }
    end
  end

  def grep_and_decremental
    @source.grep(/^.{#{@search_word.size}}$/).select do |line|
      word = line.strip

      search_word_chars.all? { |c| word.sub!(c, '') }
    end
  end

  def grep
    @source.grep(/^(#{@search_word.chars.permutation.map(&:join).join('|')})$/)
  end

  def sort
    @source.select { |line| search_word_bytes_sorted == line.bytes.sort }
  end

  def grep_and_sort
    @source.grep(/^.{#{@search_word.size}}$/).select { |line| search_word_bytes_sorted == line.bytes.sort }
  end

  private

  def search_word_bytes_sorted
    @search_word_bytes_sorted ||= (@search_word + "\n").bytes.sort
  end

  def search_word_chars
    @search_word_chars ||= @search_word.chars
  end
end

class AnagramSearchTest
  def initialize(search_word:, source:, expected_result:)
    @search_word = search_word
    @source = source
    @expected_result = expected_result
  end

  def process!(method)
    @source.rewind

    result = AnagramSearch.new(search_word: @search_word, source: @source).send(method)

    puts "Result doesn't match, expected #{@expected_result} but actual #{result}" if result != @expected_result
  end
end

def bench
  Benchmark.realtime { 10.times { yield } }
end

source = File.open('/usr/share/dict/words')

word = 'team'

puts "### Short word(#{word}) ###"

expected_result = ["mate\n", "meat\n", "meta\n", "tame\n", "team\n"]
anagram_search_test = AnagramSearchTest.new(search_word: word, source: source, expected_result: expected_result)

puts format("Decremental:          %10.6f", bench { anagram_search_test.process!(:decremental) })
puts format("Grep and decremental: %10.6f", bench { anagram_search_test.process!(:grep_and_decremental) })
puts format("Grep:                 %10.6f", bench { anagram_search_test.process!(:grep) })
puts format("Sort:                 %10.6f", bench { anagram_search_test.process!(:sort) })
puts format("Grep and sort:        %10.6f", bench { anagram_search_test.process!(:grep_and_sort) })

puts

word = 'parental'

puts "### Long word(#{word}) ###"

expected_result = ["parental\n", "paternal\n", "prenatal\n"]
anagram_search_test = AnagramSearchTest.new(search_word: word, source: source, expected_result: expected_result)

puts format("Decremental:          %10.6f", bench { anagram_search_test.process!(:decremental) })
puts format("Grep and decremental: %10.6f", bench { anagram_search_test.process!(:grep_and_decremental) })
# puts format("Grep:                 %10.6f", bench { anagram_search_test.process!(:grep) })
puts format("Sort:                 %10.6f", bench { anagram_search_test.process!(:sort) })
puts format("Grep and sort:        %10.6f", bench { anagram_search_test.process!(:grep_and_sort) })

puts

word = 'discriminator'

puts "### Very long word(#{word}) ###"

expected_result = ["discriminator\n", "doctrinairism\n"]
anagram_search_test = AnagramSearchTest.new(search_word: word, source: source, expected_result: expected_result)

puts format("Decremental:          %10.6f", bench { anagram_search_test.process!(:decremental) })
puts format("Grep and decremental: %10.6f", bench { anagram_search_test.process!(:grep_and_decremental) })
# puts format("Grep:                 %10.6f", bench { anagram_search_test.process!(:grep) })
puts format("Sort:                 %10.6f", bench { anagram_search_test.process!(:sort) })
puts format("Grep and sort:        %10.6f", bench { anagram_search_test.process!(:grep_and_sort) })

__END__

### Short word(team) ###
Decremental:            0.913660
Grep and decremental:   2.158851
Grep:                   1.646148
Sort:                   4.615171
Grep and sort:          2.209467

### Long word(parental) ###
Decremental:            1.161732
Grep and decremental:   2.703555
Grep:                   > 200
Sort:                   4.709334
Grep and sort:          2.930281

### Very long word(discriminator) ###
Decremental:            1.069861
Grep and decremental:   2.901802
Grep:                   > 999
Sort:                   4.611236
Grep and sort:          2.895310
