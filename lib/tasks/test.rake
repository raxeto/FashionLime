namespace :test do
  desc "Test for the FashionLime rake environment."
  task :FashionLime => "setup:fashionlime" do
    Rails.logger.info "Yey!"
  end
end
