module Modules
  class RandomNumberGenerator

    DEFAULT_LENGTH = 10

    def initialize(options)
      @prefix = options.fetch(:prefix, '')
      @suffix = options.fetch(:suffix, '')
      @length = options.fetch(:initial_length, DEFAULT_LENGTH)
      @alphabet = options.fetch(:alphabet, (0..9).to_a.freeze)
    end

    def generate(test, generated_randoms_count)
      length = @length
      base = @alphabet.size

      loop do
        candidate = new_random_string(length)
        return candidate if test.call(candidate)

        # If for the given range, half of all possibilities are already generated
        # increase the range by adding another digit.
        length += 1 if generated_randoms_count > base**length / 2
      end
    end

    private

      def new_random_string(length)
        @prefix + length.times.map { @alphabet.sample }.join + @suffix
      end

  end
end