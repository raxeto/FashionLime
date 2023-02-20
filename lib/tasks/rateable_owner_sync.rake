namespace :ratings do
  desc "Update User and Merchant rating field based on the ratable products and outfits."
  task :owner_update => "setup:fashionlime" do

    ActiveRecord::Base.connection.execute("
      update users
      join
      (
        select users.id, ifnull(sum(outfits.rating), 0) as sum_rating
        from users
        left join 
        (
          select user_id
          from user_roles
          where role = 'merchant'
        ) as merchant_roles on merchant_roles.user_id = users.id
        left join outfits on outfits.user_id = users.id
        where merchant_roles.user_id is null
        group by users.id
      ) as user_rateable on user_rateable.id = users.id
      set users.rating = user_rateable.sum_rating
    ")

    ActiveRecord::Base.connection.execute("
      update merchants
      left join
      (
        select merchants.id, ifnull(sum(outfits.rating), 0) as sum_ratings
        from merchants
        join profiles on profiles.owner_id = merchants.id and profiles.owner_type = 'Merchant'
        left join outfits on outfits.profile_id = profiles.id
        group by merchants.id
      ) outfits_rating on outfits_rating.id = merchants.id
      left join
      (
        select merchants.id, ifnull(sum(products.rating), 0) as sum_ratings
        from merchants
        left join products on products.merchant_id = merchants.id
        group by merchants.id
      ) products_rating on products_rating.id = merchants.id
      set merchants.rating = outfits_rating.sum_ratings + products_rating.sum_ratings
    ")

    Rails.logger.info("Ratable model owners updated successfully.")
  end
end
