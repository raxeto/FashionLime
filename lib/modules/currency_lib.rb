module Modules
  module CurrencyLib

    protected

      def currency_unit
        I18n.t 'number.currency.format.unit'
      end

      def num_to_currency(n)
        ActiveSupport::NumberHelper.number_to_currency(n).try(:strip)
      end

      def num_to_currency_without_unit(n)
        ActiveSupport::NumberHelper.number_to_currency(n, :unit => "").try(:strip)
      end

      def numbers_to_currency_range(n1, n2)
        if (n1 - n2).abs >= Conf.math.PRICE_EPSILON
          "#{num_to_currency_without_unit(n1)} - #{num_to_currency_without_unit(n2)} #{currency_unit}"
        else
          "#{num_to_currency(n1)}"
        end
      end

      def calc_price_with_discount(price, perc_discount)
        (price * (100 - perc_discount) / 100).round(2)
      end

      def calc_perc_discount(price, price_with_discount)
        if price == 0
          return 0
        end
        (100 - (price_with_discount * 100 / price)).round(2)
      end

  end
end
