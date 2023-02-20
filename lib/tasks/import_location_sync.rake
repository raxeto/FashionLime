namespace :import do
  desc "Synchronize locations table with the locations taken from excel files in the db/imports/location folder.
  Files should be the most recent version from that page - http://www.nsi.bg/nrnm/ and then converted to xlsx
  Example: rake import:location_sync"
  task :location_sync => "setup:fashionlime" do
    include Modules::SpreadsheetLib

    imp_dir = 'db/imports/locations'

    # Countries
    bg = Location.find_or_create_by(key: 'BG') do |l|
      l.name = 'България'
      l.location_type = LocationType.find_by_key('country')
    end

    # Regions
    region_location_type = LocationType.find_by_key('region')
    spreadsheet = open_spreadsheet(Rails.root + imp_dir + 'Ek_obl.xlsx')
    header_hash = get_spreadsheet_columns_hash(spreadsheet)
    (2..spreadsheet.last_row).each do |i|
      row = spreadsheet.row(i)
      Location.find_or_create_by(:key => row[header_hash["oblast"]]) do |l|
        l.name = row[header_hash["name"]]
        l.parent_id = bg.id
        l.location_type = region_location_type
      end
    end

    # Municipalities
    municipality_location_type = LocationType.find_by_key('municipality')
    spreadsheet = open_spreadsheet(Rails.root + imp_dir + 'Ek_obst.xlsx')
    header_hash = get_spreadsheet_columns_hash(spreadsheet)
    (2..spreadsheet.last_row).each do |i|
      row = spreadsheet.row(i)
      Location.find_or_create_by(:key => row[header_hash["obstina"]]) do |l|
        l.name = row[header_hash["name"]]
        l.parent = Location.find_by_key(l.key[0..2])
        if l.parent.nil?
          Rails.logger.error "Region for municipality #{l.key} not found!"
          break
        end
        l.location_type = municipality_location_type
      end
    end

    # Cities and villages
    city_location_type = LocationType.find_by_key('city')
    village_location_type = LocationType.find_by_key('village')
    monastery_location_type = LocationType.find_by_key('monastery')
    spreadsheet = open_spreadsheet(Rails.root + imp_dir + 'Ek_atte.xlsx')
    header_hash = get_spreadsheet_columns_hash(spreadsheet)
    # The first row after header contains file date so we should skip it
    (3..spreadsheet.last_row).each do |i|
      row = spreadsheet.row(i)
      Location.find_or_create_by(:key => row[header_hash["ekatte"]]) do |l|
        l.name = row[header_hash["name"]]
        l.parent = Location.find_by_key(row[header_hash["obstina"]])
        if l.parent.nil?
          Rails.logger.error "Municipality for city #{l.key} not found!"
          break
        end
        l.location_type = case row[header_hash["kind"]]
          when "1" then city_location_type
          when "3" then village_location_type
          when "7" then monastery_location_type
        end
      end
    end

    other_village_location_type = LocationType.find_by_key('other_village')
    spreadsheet = open_spreadsheet(Rails.root + imp_dir + 'Ek_sobr.xlsx')
    header_hash = get_spreadsheet_columns_hash(spreadsheet)
    (2..spreadsheet.last_row).each do |i|
      row = spreadsheet.row(i)
      Location.find_or_create_by(:key => row[header_hash["ekatte"]]) do |l|
        l.name = row[header_hash["name"]]
        parent_key = row[header_hash["area1"]][1..5] # area1 with format (code)....
        l.parent = Location.find_by_key(parent_key)
        if l.parent.nil?
          Rails.logger.error "City or municipality for other village #{l.key} not found! Parent key is #{parent_key}"
          break
        end
        l.location_type = other_village_location_type
      end
    end

    Rails.logger.info 'Locations imported successfully.'

  end
end
