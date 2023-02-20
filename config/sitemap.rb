SitemapGenerator::Sitemap.default_host = "https://fashionlime.bg"
SitemapGenerator::Interpreter.send :include, Modules::ClientUrlLib, SeoFriendlyImageHelper
SitemapGenerator::Sitemap.create_index = :auto # Generates sitemap index only if there are more than 50 000 urls - it has been tested
SitemapGenerator::Sitemap.include_root = false

SitemapGenerator::Sitemap.create do
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #

  # Common Pages
  add root_path, :priority => 0.8, :changefreq => 'daily'
  
  add contact_path, :priority => 0.3

  add terms_of_use_path,   :priority => 0.3, :changefreq => 'monthly'
  add cookies_policy_path, :priority => 0.3, :changefreq => 'monthly'
  add privacy_policy_path, :priority => 0.3, :changefreq => 'monthly'
  
  add about_us_path,                 :priority => 0.8, :changefreq => 'weekly'
  add information_new_merchant_path, :priority => 0.8, :changefreq => 'weekly'

  # Product Categories
  add all_products_path
  
  ProductCategory.where.not(:key => 'outfit').each do |c|
    if c.visible?
      # Disable men
      next if c.key == "men" || c.parent.key == "men" || (c.parent.parent.present? && c.parent.parent.key == "men")
      add products_path(:c => c.key), :priority => 0.8, :changefreq => 'daily'
    end
  end

  # Products
  Product.visible.collection_display.each do |p|
    images = []
    p.product_pictures.each do |pp|
      images.push({
        :loc => pp.picture.url(:original, :timestamp => false),
        :title => "#{p.name} във Fashion Lime",
        :caption => seo_image_description(:product_picture, pp)
      })
    end
    add product_path(p), :priority => 0.8, :changefreq => 'daily', :images => images
    add product_outfits_path(p), :priority => 0.8, :changefreq => 'daily'
  end

  # Outfit Categories
  add all_outfits_path

  OutfitCategory.all.each do |c|
    # Disable men
    next if c.key == "men"
    add outfits_path(:category => c)
    Occasion.all.each do |o|
      add outfits_path(:category => c, :occasion => o), :priority => 0.8, :changefreq => 'daily'
    end
  end

  # Outfits
  add new_outfit_path

  Outfit.visible.joins(:outfit_category).collection_display.each do |o|
    add outfit_path(o), :images => [{
      :loc => o.picture.url(:original, :timestamp => false),
      :title => "Визия #{o.name} във Fashion Lime",
      :caption => seo_image_description(:outfit, o)
    }]
  end

  # Search Pages
  SearchPage.all.each do |s|
    add search_page_path(:search_page => s), :priority => 0.8, :changefreq => 'daily'
  end

  # Blog Posts
  BlogPost.all.each do |p|
    images = []
    if p.main_picture.present? 
      images.push({
        :loc => p.main_picture.url(:original, :timestamp => false),
        :title => p.title,
        :caption => seo_image_description(:blog_post, p)
      })
    end
    add blog_post_path(:url_path => p.url_path), :priority => 0.8, :changefreq => 'daily', :images => images
  end

  # Merchant Profiles
  Merchant.active.includes(:product_collections).each do |m|
    images = []
    if m.logo.present? 
      images.push({
        :loc => m.logo.url(:original, :timestamp => false),
        :title => "Лого на #{m.name} във Fashion Lime",
        :caption => seo_image_description(:merchant, m)
      })
    end
    add merchant_profile_path(m.url_path), :priority => 0.8, :changefreq => 'daily', :images => images
    add merchant_profile_product_collections_path(m.url_path)
    add merchant_profile_products_path(m.url_path)
    add merchant_profile_outfits_path(m.url_path)
  end

  # Merchant Product Collections
  ProductCollection.joins(:merchant).includes(:merchant, :season).where("merchants.status = ?", Merchant.statuses[:active]).each do |c|
    images = []
    if c.picture.present?
      images.push({
        :loc => c.picture.url(:original, :timestamp => false),
        :title => "#{c.name} от #{c.merchant.name} във Fashion Lime",
        :caption => seo_image_description(:product_collection, c)
      })
    end
    add product_collection_path(c), :images => images
  end

  # User Profiles
  User.active.includes(:user_roles).each do |u|
    if u.regular_user?
      add user_profile_path(u.url_path)
    end
  end

end

