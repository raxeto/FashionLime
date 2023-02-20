require 'elasticsearch/model'
require 'json'
require 'set'

class Outfit < ActiveRecord::Base

  require "open-uri"

  include Elasticsearch::Model
  include Modules::EsIndexedModel
  include Modules::RateableModel

  settings do
    mappings dynamic: 'false' do
      indexes :name, analyzer: 'fashionlime_bg'
      indexes :created_at, type: 'date'
      indexes :rating, type: 'float'
      indexes :profile_id, index: :not_analyzed
      indexes :outfit_category_id, index: :not_analyzed
      indexes :id, index: :not_analyzed
      indexes :outfit_occasions do
        indexes :occasion_id, index: :not_analyzed
      end
      indexes :occasions do
        indexes :name, analyzer: 'fashionlime_bg'
      end
      indexes :creator_name, analyzer: 'fashionlime_bg'
      indexes :merchant_id, index: :not_analyzed
      indexes :min_price, type: 'float'
      indexes :max_price, type: 'float'
      indexes :product_categories, index: :not_analyzed
      indexes :product_category_names, analyzer: 'fashionlime_bg'
      indexes :product_ids, index: :not_analyzed
      indexes :trade_mark_ids, index: :not_analyzed
      indexes :trade_mark_names, analyzer: 'fashionlime_bg'
      # indexes :product_names, index: :not_analyzed
      indexes :visible, index: :not_analyzed
    end
  end

  # Attrubutes
  enum image_filter: {
    "X-PRO II": 1,
    "Sharpen": 2,
    "1977": 3,
    "Brannan": 4,
    "Brighten": 5,
    "Darken": 6,
    "Hefe": 7,
    "Inkwell": 8,
    "Nashville": 9,
    "Noise": 10
  }

  # Relations
  belongs_to :user
  belongs_to :profile
  belongs_to :outfit_category
  has_many   :outfit_product_pictures, dependent: :destroy
  accepts_nested_attributes_for :outfit_product_pictures, allow_destroy: true, :reject_if => lambda { |p| p[:instances_count].to_i <= 0}

  has_many :product_pictures, :through => :outfit_product_pictures
  has_many :products, :through => :product_pictures

  has_many :outfit_occasions, dependent: :destroy
  has_many :occasions, :through => :outfit_occasions

  has_many :ratings, as: :owner, dependent: :destroy

  # Callbacks
  before_save  :update_url_path
  after_commit :reload_outfit_cache, on: [:create, :update]

  # Attachments
  has_attached_file :picture,
    styles: {  original: ["768x768#"], medium: ["290x290#"], thumb: ["120x120#"], open_graph: ["630x630#"] },
    convert_options: { open_graph: "-background white -gravity center -extent #{Conf.attachment.facebook_recommended_size}"},
    url: Modules::SeoFriendlyAttachment.url,
    default_url: Conf.outfit.picture_default_path

  before_post_process :rename_file_name

  # Validations
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :picture, :less_than => Conf.attachment.max_file_size
  validates_presence_of :name
  validates_presence_of :outfit_category_id
  validates_presence_of :occasion_ids
  validate  :offensive_words_content
  validate  :max_occasions_count

  # Scopes
  scope :visible, -> {
    Outfit.joins('join users on users.id = outfits.user_id
                  left join merchant_users on merchant_users.user_id = users.id
                  left join merchants on merchants.id = merchant_users.merchant_id').
            where("(outfits.picture_file_name is not NULL) and ((merchants.id is null and users.status = #{User.statuses[:active]}) or
                   (merchants.id is not null and merchants.status = #{Merchant.statuses[:active]}))")
  }

  scope :with_product, -> (product_id) {
    joins(outfit_product_pictures: :product_picture)
      .where('product_pictures.product_id': product_id)
  }

  # Use this when displaying a large number of outfits using the _outfit partial.
  scope :collection_display, -> {
    includes(:occasions, profile: [:owner], user: [:user_roles, :merchant], outfit_product_pictures: [product_picture: [product: [:articles]]])
  }

  scope :trending_last_days, -> (last_days_num, limit_rows) {
    Outfit.visible.order("case when outfits.created_at >= '#{Time.zone.today - last_days_num}' then 1 else 2 end asc, outfits.rating desc").limit(limit_rows)
  }

  def fully_available?
    available_products.size == products_array.size
  end

  def partly_available?
    available_products_count = available_products.size
    available_products_count > 0 && available_products_count < products_array.size
  end

  def not_available?
    available_products.size == 0
  end

  def related_outfits
    outfit_products = self.products.includes(:colors, :occasions)
    product_picture_ids_in = self.product_picture_ids.blank? ? "0" : self.product_picture_ids.join(',')
    product_ids_in = outfit_products.blank? ? "0" : outfit_products.map { |p| p.id }.join(',')
    product_category_ids_in = outfit_products.blank? ? "0" : outfit_products.map { |p| p.product_category_id }.join(',')
    color_ids_in = product_pictures.blank? ? "0" : product_pictures.includes(product: [:colors]).map { |pp| pp.color_id || pp.product.color_ids }.flatten.join(',')
    product_occasion_ids_in = outfit_products.map { |p| p.occasion_ids }.flatten.blank? ? "0" : outfit_products.map { |p| p.occasion_ids }.flatten.join(',')
    trade_mark_ids_in = outfit_products.blank? ? "0" : outfit_products.map { |p| p.trade_mark_id || 0 }.join(',')
    merchant_ids_in = outfit_products.blank? ? "0" : outfit_products.map { |p| p.merchant_id }.join(',')

    Outfit.joins("join outfit_occasions on outfit_occasions.outfit_id = outfits.id
                  join outfit_product_pictures on outfit_product_pictures.outfit_id = outfits.id
                  join product_pictures on product_pictures.id = outfit_product_pictures.product_picture_id
                  join products on products.id = product_pictures.product_id
                  left join product_colors on product_colors.product_id = products.id
                  left join product_occasions on product_occasions.product_id = products.id
                  left join product_categories on product_categories.id = products.product_category_id
                  left join product_categories as parent_product_categories on parent_product_categories.id = product_categories.parent_id").
    where("outfits.id != #{self.id} and outfits.outfit_category_id = #{self.outfit_category_id}").
    group("outfits.id"). # My SQL can select columns which are not in the group by clause
    order("sum(case when outfit_occasions.occasion_id in (#{self.occasion_ids.join(',')}) then 48 else 0 end) +
          sum(case when product_pictures.product_id in (#{product_ids_in}) then 24 else 0 end) +
          sum(case when product_categories.id in (#{product_category_ids_in}) then 12 else 0 end) +
          sum(case when (case when product_pictures.color_id is null then product_colors.color_id else product_pictures.color_id end) in (#{color_ids_in}) then 6 else 0 end) +
          sum(case when product_occasions.occasion_id in (#{product_occasion_ids_in}) then 3 else 0 end) +
          sum(case when products.trade_mark_id in (#{trade_mark_ids_in}) then 1 else 0 end) +
          sum(case when products.merchant_id in (#{merchant_ids_in}) then 1 else 0 end) desc,
          outfits.rating desc, outfits.created_at desc").visible.uniq.limit(Conf.outfit.related_outfits_count)
  end

  def save_svg_to_png_picture(server_url, svg, scrape_url)
    beginning_time = Time.now
    return if svg.blank?
    doc = Nokogiri::XML(svg)
    image_files = []
    doc.xpath('//ns:image', 'ns' => 'http://www.w3.org/2000/svg').each do |image|
      old_link = image['xlink:href']
      old_link = old_link.gsub(/\?.*/, '') # Removes query string
      if !old_link.start_with?("data:image") # If not an embeded picture - result from image filters
        new_link = ""
        if old_link.start_with?(server_url) # Local image - don't call open because with 2 requests at the same time server will fail
          new_link = old_link.gsub(server_url, Rails.public_path.to_s)
        else
          file = Tempfile.new ['test', ".#{old_link.split('.').last}"]
          file.binmode # tempfile must be in binary mode

          # Timeout::Error will occur on timeout and the Timeout error isn't a Standart Error but even so it will be handled by delayed jobs
          open(URI.parse(old_link), :read_timeout => 10) do |data| # 10 seconds timeout
            file.write data.read
          end

          file.rewind
          image_files.push(file)
          new_link = file.path
        end
        image['xlink:href'] = new_link
      end
    end

    svg = doc.to_xml

    # Rails.logger.info(svg.to_s)

    # no clue why this sh*tty tool works only from certain folders...
    svg_file = Tempfile.new(['test-svg', '.svg'], "#{Dir.home}/web/")
    svg_file.write(svg.to_s)
    svg_file.close

    # img, data = Magick::Image.from_blob(svg) {
    #   self.format = 'SVG'
    #   self.background_color = 'transparent'
    # }
    file = Tempfile.new(['test','.png'])
    success = system("PATH=/opt/local/bin/:$PATH; convert -background white svg:#{svg_file.path} #{file.path} >>/tmp/magick.out 2>&1")
    unless success
      Rails.logger.error("Failed creating png from svg!")
    end

    # img.write(file.path)
    self.update_attributes(:picture => file)

    file.close
    file.unlink   # deletes the temp file
    svg_file.unlink
    image_files.each do |image_file|
      image_file.close
      image_file.unlink
    end

    if scrape_url
      Modules::OpenGraph.clear_cached_pages(self)
    end

    end_time = Time.now
    Rails.logger.info("Time elapsed in serializing SVG: #{(end_time - beginning_time)*1000} ms")
  end

  def product_names
    outfit_product_pictures.map { |opp| opp.product_picture.product.name }.uniq
  end

  def occasion_names
    occasions.map { |o| o.name }
  end

  def products_thumb_data(from_db: true)
    res = []
    if from_db
      pps = product_pictures
    else
      # Initialized with params outfit which products hasn't been saved to the DB yet.
      pps = ProductPicture.where(id: outfit_product_pictures.map(&:product_picture_id))
    end

    res = {}
    pps.includes(:color, product: [:colors, :merchant, articles: [:color]]).each do |pp|
      color = pp.color || pp.product.single_color
      color_id = color.try(:id)
      key = pp.product_id.to_s + '#' + color_id.to_s
      unless res.key?(key)
        res[key] = {
          id: self.id,
          product: pp.product,
          color: color,
          qty: 0,
          min_price: pp.product.min_price(false, color_id),
          max_price: pp.product.max_price(false, color_id)
        }
      end
      res[key][:qty] += self.product_qty(pp.id)
    end
    return res.values
  end

  def product_qty(product_picture_id)
    res = 0
    outfit_product_pictures.each do |opp|
      if opp.product_picture_id == product_picture_id
        res += opp.instances_count
      end
    end
    return res
  end

  def is_visible?
    is_visible_separately? && picture.present?
  end

  def is_visible_separately?
    if user.merchant.present?
      user.merchant.active?
    else
      user.active?
    end
  end

  def to_client_param
    "#{url_path}-#{id}"
  end

  def creator_name
    if user.merchant.present?
      user.merchant.name
    else
      user.username
    end
  end

  def rateable_owner
    if user.merchant.present?
      user.merchant
    else
      user
    end
  end

  def max_occasions_count
    if outfit_occasions.size > Conf.occasions.relation_max_count
      errors.add(:occasion_ids, I18n.t('activerecord.errors.models.outfit.attributes.occasion_ids', :max_count => Conf.occasions.relation_max_count))
    end
  end

  def offensive_words_content
    add_offensive_content_error = false
    if name.present? && Obscenity.profane?(name)
      errors.add(:name, I18n.t('errors.messages.offensive_words'))
      add_offensive_content_error = true
    end

    if !add_offensive_content_error && serialized_json.present?
      objects = JSON.parse(serialized_json)["objects"]
      objects.each do |o|
        if o["type"] == "text"
          if Obscenity.profane?(o["text"])
            add_offensive_content_error = true
            break
          end
        end
      end
    end
    if add_offensive_content_error
      errors.add(:offensive_words_content, "Бяха засечени обидни думи във визията и тя не може да бъде запаметена.")
    end
  end

  def as_indexed_json(options={})
    json = self.as_json(
      include: { outfit_occasions: { only: :occasion_id },
                 occasions: { only: :name },
               },
      except: [:updated_at, :url_path, :serialized_json, :serialized_svg, :picture_file_name,
                :picture_content_type, :picture_file_size, :picture_updated_at])

    json["min_price"] = 0
    json["max_price"] = 0
    self.products_thumb_data.each do |p|
      json["min_price"] += (p[:min_price] || 0)
      json["max_price"] += (p[:max_price] || 0)
    end

    json["product_categories"] = ProductCategory.all_uniq_ids(
      products.pluck(:product_category_id))
    json["product_category_names"] =
        ProductCategory.where(id: json["product_categories"]).pluck(:name)
    json["product_ids"] = products.pluck(:id)
    json["trade_mark_ids"] = Set.new(products.pluck(:trade_mark_id)).to_a.select do |id|
      id.present?
    end
    json["trade_mark_names"] = TradeMark.where(id: json["trade_mark_ids"]).pluck(:name)
    json["visible"] = is_visible?

    json["merchant_id"] = Set.new(products.pluck(:merchant_id)).to_a
    json["creator_name"] = creator_name

    return json
  end

  def update_url_path
    self.url_path = name.parameterize
    true
  end

  def reload_outfit_cache
    Modules::OutfitJsonBuilder.instance.refresh_outfit_cache(id)
  end

  def self.es_search(query = '', count = nil, offset = nil, filters = [],
      sort_by = nil, all_words_should_match = false, sort_by_ids = nil)
    es_query = Modules::ElasticSearchHelper.format_query(query, count, offset,
        filters, sort_by, ['name^3', 'creator_name^2', 'product_category_names',
            'occasions.name', 'trade_mark_names'],
        all_words_should_match, sort_by_ids)
    return Outfit.search(es_query).records
  end

  def capped_name
    if self.name.size > Conf.outfit.capped_name_max_length
      return self.name[0...Conf.outfit.capped_name_max_length] + '...'
    end
    return self.name
  end

  def rename_file_name
    Modules::SeoFriendlyAttachment.set_file_name(self, picture, name.parameterize)
  end

  def available_products
    products_array.select { |p| p.available? }
  end

  def products_array
    outfit_product_pictures.map { |opp| opp.product_picture.product }.uniq
  end

end

Modules::ElasticSearchHelper.setup_elastic_search_indexes(Outfit) if Rails.env.development?
