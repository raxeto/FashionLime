module Modules
  module SpreadsheetLib

    def open_spreadsheet_from_uploaded_file(file)
      open_spreadsheet(file.path, file.original_filename)
    end

    def open_spreadsheet(file_path, original_filename = '')
      filename = original_filename
      if filename.blank?
        filename = File.basename(file_path)
      end

      case File.extname(filename)
      when ".csv"  then Roo::CSV.new(file_path)
      when ".tsv"  then Roo::CSV.new(file_path, csv_options: {col_sep: "\t"})
      when ".xlsx" then Roo::Excelx.new(file_path)
      when ".ods"  then Roo::OpenOffice.new(file_path)
      else raise "Unknown file type: #{filename}"
      end
    end

    def get_spreadsheet_columns_hash(spreadsheet)
      spreadsheet.row(1).map.with_index { |x, i| 
        [ x.present? ? Modules::StringLib.unicode_downcase(x).delete(' ') : nil, i] 
      }.select {|c| 
        c.first.present?
      }.to_h
    end

  end
end
