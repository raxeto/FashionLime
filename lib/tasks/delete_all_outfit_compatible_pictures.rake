desc "Delete all product pictures with outfit_compatible = true without ES refresh and open graph clear cache"
task :delete_all_outfit_compatible_pictures => "setup:fashionlime" do
  CustomTask.begin_execute("UPLOAD_OUTFIT_PICTURES")

  ProductPicture.where(:outfit_compatible => 1).each do |pp|
    begin
      pp.destroy!()
    rescue ActiveRecord::RecordNotDestroyed
       Rails.logger.error("We could not delete a product picture with ID #{pp.id}.")
    end
  end

  CustomTask.end_execute("UPLOAD_OUTFIT_PICTURES")
  
  Rails.logger.info("Outfit pictures delete task completed.")
end