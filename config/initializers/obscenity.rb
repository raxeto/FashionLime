# Merge default blacklist to the application blacklist 
app_offensive_words = YAML.load(File.read("config/locales/offensive_words.bg.yml"))["bg"]["obscenity"]["offensive_words"]
obsenity_offensive_words = YAML.load(File.read(Obscenity.configure.blacklist))

Obscenity.configure do |config|
  config.blacklist   = obsenity_offensive_words + app_offensive_words
  config.replacement = :stars
end


