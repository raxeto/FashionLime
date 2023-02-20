module Modules
  module DateLib

    protected

      def date_time_to_s(d)
        if d.nil?
          return ''
        end
        I18n.l d, :format => :long
      end

      def date_to_s(d)
        if d.nil?
          return ''
        end
        I18n.l d.to_date, :format => :long
      end

      def date_to_s_short(d)
        if d.nil?
          return ''
        end
        I18n.l d.to_date, :format => :short_with_weekday
      end

  end
end
