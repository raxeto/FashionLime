module Modules
  module RandLib

    protected

      def self.six_digits
        self.n_digits(6)
      end

      def self.n_digits(n)
        # Random.new.bytes(n) returns random string
        # .bytes method returns an array of bytes for that random string (bytes are from 0 to 255)
        # .join concatenates bytes in a string
        # [0,n] gets the first n symbols from the string
        Random.new.bytes(n).bytes.join[0,n]
      end

  end
end
