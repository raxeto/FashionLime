module Modules
  module StringLib

    protected

      def truncate_string(s, n = 50)
        truncated = s
        if truncated.present? && truncated.length > n
          truncated = truncated.truncate(n, :separator => ' ')
        end
        return truncated
      end

      # Normal Ruby downcase method doesn't work on cyrillic letters
      def self.unicode_downcase(s)
        return nil if s.nil?
        s.mb_chars.downcase.to_s
      end

      def self.unicode_upcase(s)
        return nil if s.nil?
        s.mb_chars.upcase.to_s
      end

      def self.to_number_array(s)
        if s.nil?
          return []
        end
        s.split(',').map { |i| i.to_i }
      end

      def self.is_number?(s)
        begin
          Float(s)
        rescue
          return false
        end
        return true
      end

  end
end
