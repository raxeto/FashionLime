module Modules
  module RateableModel

    def user_rating(profile_id)
      Rating.where(profile_id: profile_id, owner: self).take.try(:rating).try(:to_i)
    end

    # Use this method when for a single profile ID we are interested in more than one rating for different models. The caching
    # is for the DB query and is performed by rails itself.
    def cached_user_rating(profile_id, model_id)
      r = Rating.where(:profile_id => profile_id, :owner_type => self.class.name).order("owner_id").bsearch {|x| x.owner_id >= model_id}
      if !r.nil? && r.owner_id == model_id
        return r.rating
      end
      return nil
    end

  end
end
