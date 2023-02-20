require 'net/imap'

desc "Refreshes the cache for a tenth of the outfits"
task :refresh_outfits_cache => "setup:fashionlime" do
  t = Time.now + 59.seconds

  # We want to refresh all outfits in 10 invocations, thus we need to know which
  # invocation we are in atm so that we know which outfits to update.
  start_index = (t.min / 6).to_i
  all_outfits_count = Outfit.count
  batch_size = ((all_outfits_count + 9) / 10).to_i
  Rails.logger.info("Working with #{all_outfits_count} outfits. Batch size: #{batch_size}. Index: #{start_index}")
  Outfit.order(:id).offset(start_index * batch_size).limit(batch_size).collection_display.each do |outfit|
    Modules::OutfitJsonBuilder.instance.refresh_outfit_cache_for_outfit(outfit)
  end
  Rails.logger.info("Done refreshing the outfits cache")
end
