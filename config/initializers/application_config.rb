require 'conf'

# Math constants.
Conf.configure('math') do |config|
  config.QTY_EPSILON = 0.0005
  config.PRICE_EPSILON = 0.005
end

# Counter initial constants.
Conf.configure('counters') do |config|
  config.users_iniatial = 1233
  config.merchants_iniatial = 116
  config.products_iniatial = 1506
  config.outfits_iniatial = 788
end

# User model.
Conf.configure('user') do |config|
  # DEPRECATED: the guests no longer have passwords
  config.guest_user_password = "xD761*547$6duqpem^8801"
  config.avatar_default_path = "/avatars/default-:style.jpg"
  config.guest_user_rand_username_attempts = 20
end

# Merchane model.
Conf.configure('merchant') do |config|
  config.logo_default_path = "/merchant/default-merchant-image-:style.jpg"
  config.capped_name_max_length = 15
  config.return_days_min = 14
end

# Attachments.
Conf.configure('attachment') do |config|
  config.max_file_size = 5.megabytes
  config.facebook_recommended_size = "1200x630"
end

Conf.configure('product') do |config|
  config.picture_default_path = "/product/default-product-image-:style.jpg"
  config.capped_name_max_length = 15
  config.related_products_count = 10
  config.suitable_products_count = 10
  config.import_pictures_max_count = 100
  config.import_username = "admin"
end

Conf.configure('product_collection') do |config|
  config.picture_default_path = "/product_collection/default-product-collection-image-:style.jpg"
end

Conf.configure('profiles') do |config|
  config.visible_collections_count = 3
  config.visible_products_count = 4
  config.visible_merchant_outfits_count = 4
  config.visible_user_outfits_count = 8
  config.visible_user_favorite_products_count = 8
end

Conf.configure('order') do |config|
  config.return_max_attempts = 4
  config.max_items = 50
end

Conf.configure('search') do |config|
  config.initial_item_count = 30
end

Conf.configure('occasions') do |config|
  config.relation_max_count = 2
end

Conf.configure('outfit') do |config|
  config.picture_default_path = "/outfit/default-outfit-image-:style.jpg"
  config.capped_name_max_length = 15
  config.related_outfits_count = 15
  config.text_colors =  [
    ["#000000","Черен"],
    ["#864d1d", "Кафяв"],
    ["#d2b48c", "Бежов"],
    ["#999999","Сив"],
    ["#ffffff", "Бял"],
    ["#000080","Тъмно син"],
    ["#2196f3", "Синьо"],
    ["#80bfff","Светло син"],
    ["#40e0d0","Тюркоазен"],
    ["#1e7b1e","Тъмно зелен"],
    ["#90EE90","Светло зелен"],
    ["#9c27b0", "Светло лилав"],
    ["#673ab7", "Тъмно лилав"],
    ["#a00d3d", "Бордо"],
    ["#c3131b", "Червен"],
    ["#ff4400", "Корал"],
    ["#ffc107", "Светло оранжев"],
    ["#ff9800", "Тъмно оранжев"],
    ["#ffff80", "Жълт"],
    ["#ff99ff", "Розов"],
    ["#ff33cc", "Фуксия"]
  ]
  config.text_font_families = [
    ['Arial, Helvetica, sans-serif', 'Arial'],
    ['"Arial Black", Gadget, sans-serif', 'Arial Black'],
    ['"Comic Sans MS", cursive, sans-serif', 'Comic Sans MS'],
    ['"Courier New", Courier, monospace', 'Courier New'],
    ['Georgia, serif', 'Georgia'],
    ['Impact, Charcoal, sans-serif', 'Impact'],
    ['"Lucida Console", Monaco, monospace', 'Lucida Console'],
    ['"Lucida Sans Unicode", "Lucida Grande", sans-serif', 'Lucida Sans Unicode'],
    ['"Palatino Linotype", "Book Antiqua", Palatino, serif', 'Palatino Linotype'],
    ['Tahoma, Geneva, sans-serif', 'Tahoma'],
    ['"Times New Roman", Times, serif', 'Times New Roman'],
    ['"Trebuchet MS", Helvetica, sans-serif', 'Trebuchet MS'],
    ['Verdana, Geneva, sans-serif', 'Verdana'],
    ['"Comfortaa", cursive', 'Comfortaa'],
    ['"Ruslan Display", cursive', 'Ruslan Display'],
    ['"Stalinist One", cursive', 'Stalinist One'],
    ['"Bad Script", cursive', "Bad Script"],
    ['"Marck Script", cursive', "Marck Script"],
    ['"Poiret One", cursive', "Poiret One"],
    ['"Jura", sans-serif', "Jura"]
  ]
end

Conf.configure('blog_post') do |config|
  config.related_blog_posts_count = 4
end

# Google analytics settings.
Conf.configure('google_analytics') do |config|
  config.service_account_email = 'account-1@dressmeservice.iam.gserviceaccount.com'
  config.key_file = 'config/credentials/DressMeService-da1ec8ecf647.p12'
  config.view_id = 'ga:132562454' # Located in Admin->View Settings in GA Account (View ID)
end

# Merchant shipment model.
Conf.configure('shipment') do |config|
  config.visible_count = 6
end

# Merchant activation steps.
Conf.configure('merchant_activation') do |config|
  config.steps_count = 4
  config.profile_step = 1
  config.payments_step = 2
  config.shipments_step = 3
  config.size_chart_step = 4
end

Conf.configure('email_promotions') do |config|
  config.hash_secret = Digest::SHA1.hexdigest("dressMeMadaf4ka!")
end

Conf.configure('html_constants') do |config|
  config.max_tab_index = 32767
end

Conf.configure('facebook') do |config|
  config.app_id = '1725490347665325'
  config.app_secret = 'd77541d1dd2d6a4a960c078aed88bafb'
  config.pixel_id = '1844251189170604'
end

Conf.configure('contact') do |config|
  config.clients_phone = "02 468 90 38"
  config.clients_phone_number = "024689038"
  config.clients_email = "info@fashionlime.bg"
  config.merchants_phone = "02 468 90 38"
  config.merchants_phone_number = "024689038"
  config.merchants_email = "sales@fashionlime.bg"
  config.address = 'гр. София, бул. "Шипченски проход" 18, офис 104, П.К. 1113'
  config.address_google_maps = "https://www.google.com/maps/place/%D0%B1%D1%83%D0%BB.+%E2%80%9E%D0%A8%D0%B8%D0%BF%D1%87%D0%B5%D0%BD%D1%81%D0%BA%D0%B8+%D0%BF%D1%80%D0%BE%D1%85%D0%BE%D0%B4%E2%80%9C+18,+1113+%D0%A1%D0%BE%D1%84%D0%B8%D1%8F,+%D0%91%D1%8A%D0%BB%D0%B3%D0%B0%D1%80%D0%B8%D1%8F/@42.6791808,23.3582815,17.04z/data=!4m5!3m4!1s0x40aa85c14513b051:0x39c0e5de9371f48b!8m2!3d42.6791116!4d23.3604778"
  config.company_name = "Фешън Лайм ООД"
  config.company_bulstat = "204422168"
  config.facebook_url = "https://www.facebook.com/fashionlime.bg/"
  config.google_plus_url = "https://plus.google.com"
  config.instagram_url = "https://www.instagram.com/fashionlime.bg/"
  config.office_working_hours_text = "от понеделник до петък от 9:30 до 18:30ч."
  config.support_working_hours_text = "от понеделник до петък от 9:30 до 18:30ч."
end

Conf.configure('payments') do |config|
  config.epay_exp_date_offset = 31.days
  config.epay_test_min_code = 'D159695488'
  config.epay_test_secret = 'AIT8QZJC9JU18ACYJA9FUQQW3IFSL0G833HKY4ZN69GTPPTVIUJL2VLKGQK7X3UE'
  config.epay_failed_code = 'CODE_MISSING'
  config.epay_secret_visible_symbols = 16
  config.no_code          = 'NOCODE'
end

Conf.configure('marketing') do |config|
  config.allowed_query_params = ["utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content"]
end
