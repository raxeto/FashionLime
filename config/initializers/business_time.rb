Dir.foreach('config/locales/holidays') do |folder|
  next if folder == '.' || folder == '..'
  # TODO - I18n translations are not loaded yet in initializers - make this function in after initialize event
  holidays = YAML.load(File.read("config/locales/holidays/#{folder}/bg.yml"))["bg"]["holidays"]["y#{folder}"]
  holidays.each do |d|
    BusinessTime::Config.holidays << Date.parse(d)
  end
end