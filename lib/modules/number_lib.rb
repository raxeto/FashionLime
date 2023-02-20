module Modules
  module NumberLib

    protected

      def num_with_auto_precision(n, max_precision: 2)
        ActiveSupport::NumberHelper.number_to_rounded(n, strip_insignificant_zeros: true, precision: max_precision)
      end

  end
end
