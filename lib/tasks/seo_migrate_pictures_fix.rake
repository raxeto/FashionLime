namespace :seo do
  desc "Fix the outfit picture serialized json to match the real file url."
  task :migrate_pictures_fix => "setup:fashionlime" do
     changed_outfits = ""
     ProductPicture.all.each do |pp|
      Outfit.all.each do |o|
        if (o.serialized_json.include?("/product_pictures/#{pp.id}/"))
          o.serialized_json = o.serialized_json.gsub(/product_pictures\/#{pp.id}\/pictures\/medium\/[^?"]+/, "product_pictures/#{pp.id}/pictures/medium/#{pp.picture_file_name}")
          if (o.serialized_json_changed?)
            changed_outfits << ",#{o.id.to_s}"
            o.save
          end
        end
      end
    end
    Rails.logger.info "CHANGED OUTFITS" + changed_outfits
  end
end
