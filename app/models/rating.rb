class Rating < ActiveRecord::Base

  # Relations
  belongs_to :owner, polymorphic: true
  belongs_to :profile
  belongs_to :user

  def self.increase(model, user)
    self.rate_model(model, user, 1)
  end

  def self.decrease(model, user)
    self.rate_model(model, user, -1)
  end

  def self.invalidate(model, user)
    self.rate_model(model, user, 0)
  end

  private

  def self.rate_model(model, user, rating)
    return if model.nil?
    params =
    {
      owner: model,
      profile_id: user.profile_id,
      user_id: user.id,
      rating: rating
    }
    rating_was = 0.0, success = true
    rating_instance = Rating.where(profile_id: user.profile_id, owner: model).take
    begin
      if rating_instance.nil?
        rating_was = 0.0
        success = Rating.create(params).valid?
      else
        rating_was = rating_instance.rating
        success = rating_instance.update_attributes(params)
      end
    rescue ActiveRecord::ActiveRecordError
      success = false
    end
    if success
      model.class.update_counters(model.id, :rating => (rating - rating_was))
      model.rateable_owner.class.update_counters(model.rateable_owner.id, :rating => (rating - rating_was))
      model.reload
      Modules::DelayedJobs::EsIndexer.schedule('update_document', model) if model.class.respond_to?('__elasticsearch__')
      if model.instance_of?(Product)
        Modules::ProductJsonBuilder.instance.refresh_product_cache(model.id) if model.present?
      elsif model.instance_of?(Outfit)
        Modules::OutfitJsonBuilder.instance.refresh_outfit_cache(model.id) if model.present?
      end
    else
      Rails.logger.error("Error occured when rate model of type #{model.class.name} and ID #{model.id}")
    end
  end

end
