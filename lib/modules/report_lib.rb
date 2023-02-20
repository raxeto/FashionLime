module Modules
  module ReportLib

    def generate_report(params, field_to_sql, sumators, main_table, joins, filters, custom_filter_clause)
      p = params.permit(:report_type, selected_fields_list: [])

      @reportType = p[:report_type]
      @selectedFields = p[:selected_fields_list]

      return if p[:selected_fields_list].nil?

      field_list = ""
      field_alias_list = ""

      p[:selected_fields_list].each do |field|
        sql = field_to_sql[field.to_sym]
        unless sql.blank?
          unless sumators.include? field.to_sym
            unless field_list.blank?
              field_list << ", "
            end
            field_list << sql
          end

          unless field_alias_list.blank?
            field_alias_list << ", "
          end
          field_alias_list << "#{sql} as #{field}"
        end
      end

      return if field_list.blank? || field_alias_list.blank?

      sql_filter = construct_where(params, filters)
      unless custom_filter_clause.blank?
        unless sql_filter.blank?
          sql_filter << " AND "
        end
        sql_filter << custom_filter_clause
      end

      sql = "select #{field_alias_list}
             from #{main_table}
             #{joins} 
             #{sql_filter.blank? ? "" : " where " + sql_filter}
             group by #{field_list}
             order by #{field_list}"

      @records = ActiveRecord::Base.connection.select_all(sql)
    end

    def construct_where(params, filters)
      sql = ""
      selected_filters = params[:selected_filters]

      filters.each do |filter_name, f|
        value = selected_filters[filter_name.to_sym]
        unless value.blank?
          filter_sql = ""
          case f[:type]
          when :between_date
            unless value[:date_from].blank? || value[:date_to].blank?
              date_from = value[:date_from].to_date.to_s(:db) 
              date_to = value[:date_to].to_date.to_s(:db)
              filter_sql = "date(#{f[:sql]}) between '#{date_from}' and '#{date_to}'"
            end
          when :multiselect
            key_type = f[:key_type]
            list = value.select { |v| !v.blank? }
            unless list.blank?
              if key_type == "string"
                values_sql = list.collect { |v| ActiveRecord::Base.connection.quote(v)}.join(',')
              else
                values_sql = list.collect { |v| v.to_i }.join(',') 
              end
              filter_sql = "#{f[:sql]} in (#{values_sql})"
            end
          when :string
            value = "%#{value}%"
            value = ActiveRecord::Base.connection.quote(value)
            filter_sql = "#{f[:sql]} like #{value}"
          end
          unless filter_sql.blank?
            unless sql.blank?
              sql << " AND "
            end
            sql << filter_sql
          end
        end
      end      
      sql
    end

    def date_part(sql, part)
      case part
      when :date
        "DATE_FORMAT(#{sql}, '%d-%m-%Y')"
      when :month
        "DATE_FORMAT(#{sql}, '%M')"
      when :quarter
        "CONCAT('Q', CAST(QUARTER(#{sql}) AS CHAR))"
      when :year
        "DATE_FORMAT(#{sql}, '%Y')"
      when :day
        "DATE_FORMAT(#{sql}, '%W')"
      end
    end

  end
end
