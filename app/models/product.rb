require 'elasticsearch/model'
require 'json'

class Product < ActiveRecord::Base

  include Elasticsearch::Model
  include Modules::DateLib
  include Modules::RateableModel
  include Modules::EsIndexedModel

  settings do
    mappings dynamic: 'false' do
      indexes :name, analyzer: 'fashionlime_bg'
      indexes :description, analyzer: 'fashionlime_bg'
      indexes :created_at, type: 'date'
      indexes :rating, type: 'float'
      indexes :merchant_id, index: :not_analyzed
      indexes :id, index: :not_analyzed
      indexes :trade_mark do
        indexes :id, index: :not_analyzed
        indexes :name, analyzer: 'fashionlime_bg'
      end
      indexes :product_category do
        indexes :id, index: :not_analyzed
        indexes :name, analyzer: 'fashionlime_bg'
      end
      indexes :outfit_compatible, index: :not_analyzed
      indexes :outfit_compatible_only_for_merchant, index: :not_analyzed
      indexes :visible, index: :not_analyzed
      indexes :product_sizes do
        indexes :size_id, index: :not_analyzed
      end
      indexes :merchant do
        indexes :name, analyzer: 'fashionlime_bg'
      end
      indexes :occasions do
          indexes :name, analyzer: 'fashionlime_bg'
          indexes :id, index: :not_analyzed
      end
      indexes :product_colors do
        indexes :color_id, index: :not_analyzed
        indexes :name, analyzer: 'fashionlime_bg'
      end
      indexes :articles do
        indexes :price_with_discount, type: 'float'
      end
    end
  end

  # Relations
  belongs_to  :trade_mark
  belongs_to  :product_collection
  belongs_to  :user
  belongs_to  :merchant
  belongs_to  :product_category

  has_many :product_sizes, dependent: :destroy
  has_many :sizes, :through => :product_sizes

  has_many :product_colors, dependent: :destroy
  has_many :colors, :through => :product_colors

  has_many :product_occasions, dependent: :destroy
  has_many :occasions, :through => :product_occasions

  has_many :product_pictures, -> { order(:order_index) }, dependent: :destroy
  accepts_nested_attributes_for :product_pictures, allow_destroy: true, :reject_if => lambda { |p| p[:id].blank? && p[:picture].blank? }

  has_many :articles, dependent: :destroy
  accepts_nested_attributes_for :articles, allow_destroy: false, update_only: true

  has_many :article_quantities, :through => :articles

  has_many :campaign_object, as: :object, dependent: :restrict_with_error
  has_many :home_page_object, as: :object, dependent: :restrict_with_error

  has_attached_file :catalog_picture,
    styles: {  original: ["1200x628#"] },
    url: Modules::SeoFriendlyAttachment.url

  has_attached_file :catalog_square_picture,
    styles: {  original: ["768x1024#"] },
    convert_options: { original: "-background white -gravity center -extent 1024x1024"},
    url: Modules::SeoFriendlyAttachment.url

  # Callbacks
  before_save  :sync_articles
  before_save  :update_url_path
  after_commit :reload_product_cache, on: [:create, :update]
  after_commit :update_es_indexes_on_save, on: [:update]
  after_commit :update_es_indexes_on_destroy, on: [:destroy]
  after_commit :clear_cache, on: [:update]
  after_commit :update_product_category_status, on: [:create, :destroy]
  after_commit :update_product_category_status_on_update, on: [:update]

  # Validations
  validates_presence_of :name
  validates_presence_of :status
  validates_presence_of :product_category_id

  validate  :at_least_one_size, :at_least_one_color, :unique_size_category, :max_occasions_count

  validates_attachment_content_type :catalog_picture, content_type: /\Aimage\/.*\Z/
  validates_attachment_size :catalog_picture, less_than: Conf.attachment.max_file_size

  # Import validations
  validates_numericality_of :imp_price, :greater_than => 0, :allow_nil => :true
  validates_numericality_of :imp_perc_discount, :greater_than_or_equal_to => 0, :less_than => 100, :allow_nil => :true
  validates_numericality_of :imp_qty, :greater_than_or_equal_to => 0, :allow_nil => :true
  validates_numericality_of :base_price, :greater_than => 0, :unless => Proc.new { |p| p.base_price.blank? }
  validates_numericality_of :min_available_qty, :greater_than_or_equal_to => 0, :allow_nil => :true

  # Attributes
  enum status: { normal: 1, hidden: 2, not_active: 3 }
  # used for import functions
  attr_accessor :imp_price, :imp_perc_discount, :imp_price_with_discount, :imp_qty
  attr_accessor :base_price

  # Scopes
  scope :visible, -> {
    joins(:merchant).where("products.status in (#{statuses[:normal]}, #{statuses[:not_active]}) and merchants.status = #{Merchant.statuses[:active]}")
  }

  scope :collection_display, -> {
    includes(:merchant, :colors, articles: [:color], product_pictures: [:color, product: [:merchant, :occasions]])
  }

  scope :without_outfit_pictures, -> {
    visible.includes(:product_pictures).where(
      :id =>
        Product.joins('left join product_pictures on product_pictures.product_id = products.id and product_pictures.outfit_compatible = 1').
        where('product_pictures.id is null').
        select(:id).
        pluck(:id)
    ).order(
      id: :desc
    )
  }

  scope :with_outfit_pictures, -> {
    visible.includes(:product_pictures).where(
      :id =>
        Product.joins('left join product_pictures on product_pictures.product_id = products.id and product_pictures.outfit_compatible = 1').
        where('product_pictures.id is not null').
        select(:id).
        pluck(:id)
    ).order(
      id: :desc
    )
  }

  public

  def client_json
    return {
      id: id,
      name: name,
      trademark: trade_mark.try(:name) || "",
      description: truncated_description,
      collection: product_collection.try(:full_name),
      general_price_text: general_price_text,
      status: status_i18n,
      created_at: date_time_to_s(created_at),
      updated_at: date_time_to_s(updated_at),
    }.to_json
  end

  def truncated_description
    truncated = description
    if truncated.present? && truncated.length > 50
      truncated = truncated.truncate(50, :separator => ' ')
    end
    return truncated
  end

  def rateable_owner
    self.merchant
  end

  def outfit_pictures
    pictures = product_pictures.select { |pp| pp.outfit_compatible == 1 }
    pictures.sort_by { |p| p.order_index }
  end

  def non_outfit_pictures
    pictures = product_pictures.select { |pp| pp.outfit_compatible == 0 }
    pictures.sort_by { |p| p.order_index }
  end

  class DefaultProductPicture

    def url(style)
      Conf.product.picture_default_path.gsub(':style', style.to_s)
    end

  end

  def main_product_picture(color_id: nil)
    if non_outfit_pictures.empty?
      return nil
    end
    pp = []
    if color_id.nil?
      pp = non_outfit_pictures
    else
      pp = non_outfit_pictures.select { |pp| pp.color_id.nil? || pp.color_id == color_id }
      if pp.empty?
        pp = non_outfit_pictures
      end
    end
    # Previous: product_pictures.first.picture => but if the product_pictures are included into join then the order in the relation is undefined
    pp.min_by(&:order_index)
  end

  def main_picture(color_id: nil)
    mpp = main_product_picture(color_id: color_id)
    if mpp.nil?
      return DefaultProductPicture.new
    end
    mpp.picture
  end

  def main_picture_id
    mpp = main_product_picture(color_id: nil)
    if mpp.nil?
      return 0
    end
    if product_pictures.empty?
      return 0
    end
    return mpp.id
  end

  # This method returns no picture if there is no picture with this color
  # This is the difference with main_product_picture method
  def main_picture_for_color(color_id)
    pp = non_outfit_pictures.select { |pp| pp.color_id == color_id }
    if pp.empty?
      return nil
    end
    pp.min_by(&:order_index)
  end

  def pictures
    unless product_pictures.empty?
      product_pictures.map { |pp| pp.picture }
    else
      [ DefaultProductPicture.new ]
    end
  end

  def main_outfit_picture
    outfit_pictures.min_by(&:order_index)
  end

  def main_outfit_picture_id
     return main_outfit_picture.id
  end

  def colors_sort_by_pictures
    articles.map {
      |a| a.color 
    }.uniq.sort_by {
      |c| main_picture_for_color(c.id).try(:order_index) || Float::INFINITY
    }
  end

  def active_articles
    return articles.select { |a| a.available? }
  end

  def available?
    active_articles.length > 0
  end

  def active_sizes
    return active_sizes_for_color(nil)
  end

  def active_sizes_for_color(color)
    articles = active_articles
    unless color.nil?
      articles = articles.select {|a| a.color_id == color.id }
    end

    return articles.map { |a| a.size }.uniq.sort_by { |s| s[:order_index] }
  end

  def active_sizes_and_prices_for_color(color)
    articles = active_articles
    unless color.nil?
      articles = articles.select {|a| a.color_id == color.id }
    end
    return articles.map { |a| {size_id: a.size_id, price: a.price, price_with_discount: a.price_with_discount}}
  end

  def arts_for_color(active, color_id)
    arts = active ? active_articles : articles
    if !color_id.nil?
      arts = arts.select { |a| a.color_id == color_id }
    end
    arts
  end

  def has_different_prices?(active: true)
    arts = arts_for_color(active, nil)
    return false if arts.size == 0
    pr = arts.first.price
    pr_with_disc = arts.first.price_with_discount
    arts.each do |a|
      if ((a.price - pr).abs >= Conf.math.PRICE_EPSILON) || ((a.price_with_discount - pr_with_disc).abs >= Conf.math.PRICE_EPSILON)
        return true
      end
    end
    return false
  end

  def has_different_perc_discount?(active: true)
    arts = arts_for_color(active, nil)
    return false if arts.size == 0
    disc = arts.first.perc_discount
    arts.each do |a|
      if (a.perc_discount - disc).abs >= Conf.math.PRICE_EPSILON
        return true
      end
    end
    return false
  end

  def price(active: true)
    return nil if has_different_prices?(active: active)
    arts = arts_for_color(active, nil)
    arts.first.price
  end

  def price_with_discount(active: true)
    return nil if has_different_prices?(active: active)
    arts = arts_for_color(active, nil)
    arts.first.price_with_discount
  end

  def perc_discount(active: true)
    return nil if has_different_perc_discount?(active: active)
    arts = arts_for_color(active, nil)
    arts.first.perc_discount
  end

  def has_price_range?(active: true)
    (min_price(active) - max_price(active)).abs >= Conf.math.PRICE_EPSILON
  end

  def general_price_text(active: true)
    numbers_to_currency_range(min_price(active), max_price(active))
  end

  def min_price(active, color_id= nil)
    arts_for_color(active, color_id).map(&:price_with_discount).min || 0
  end

  def max_price(active, color_id= nil)
    arts_for_color(active, color_id).map(&:price_with_discount).max || 0
  end

  def catalog_price
    is_available = normal? && available?
    return is_available ? max_price(true) : max_price(false)
  end

  def is_visible?
    if hidden?
      return false
    end

    return merchant.active?
  end

  def self.is_visible_clause
    "products.status != #{Product.statuses[:hidden]} and merchants.status = #{Merchant.statuses[:active]}"
  end

  def single_color
    if colors.size == 1
      return colors[0]
    end
    return nil
  end

  def to_client_param
    "#{url_path}-#{id}"
  end

  def as_indexed_json(options={})
    json = self.as_json(
      include: { product_sizes:     { only: :size_id },
                 product_colors:    { only: :color_id },
                 trade_mark:        { only: [:name, :id] },
                 occasions:         { only: [:name, :id] },
                 product_category:  { only: [:name, :id] },
                 merchant: { only: :name },
               },
      except: [:updated_at, :url_path, :status, :product_collection_id])

    json["articles"] = []
    json_articles = articles
    if available? && !not_active?
      # We have articles that are available for sale - use only their price.
      # Otherwise we would use all articles.
      json_articles = active_articles
    end

    json_articles.each do |a|
      json["articles"] << { "price_with_discount": a.price_with_discount }
    end

    json["outfit_compatible"] = outfit_pictures.present?
    json["outfit_compatible_only_for_merchant"] = merchant.setting_value("PRODUCTS_ACCESSIBLE_ONLY_FOR_OWNER_OUTFITS") == 'true' ? merchant_id : 0

    json["visible"] = is_visible?
    (json["product_colors"] || []).each do |pc|
      color = Color.find(pc["color_id"])
      pc["name"] = color.name if color.present?
    end

    return json
  end

  def self.es_search(query = '', count = nil, offset = nil, filters = [],
      sort_by = nil, all_words_should_match = false, sort_by_ids = nil)
    es_query = Modules::ElasticSearchHelper.format_query(query, count, offset,
        filters, sort_by, ['name', 'product_colors.name', 'trade_mark.name',
            'description', 'merchant.name', 'occasions.name', 'product_category.name'],
        all_words_should_match, sort_by_ids)

    res = Product.search(es_query)

    products = res.records
    # TODO: move the score cutoffs as constants.
    return Modules::ElasticSearchHelper.filter_by_score(products, res, min_score: 0.5, percent_max: 20)
  end

  def capped_name
    if self.name.size > Conf.product.capped_name_max_length
      return self.name[0...Conf.product.capped_name_max_length] + '...'
    end
    return self.name
  end

  def size_chart
    merchant.size_charts.includes(size_chart_descriptors: [:size]).where(:size_category_id => sizes[0].size_category_id).first
  end

  def occasion_names
    occasions.map { |o| o.name }
  end

  def related_products
    Product.joins("join merchants on merchants.id = products.merchant_id
                   left join product_colors on product_colors.product_id = products.id
                   left join product_occasions on product_occasions.product_id = products.id
                   left join product_categories on product_categories.id = products.product_category_id
                   left join product_categories as parent_product_categories on parent_product_categories.id = product_categories.parent_id").
    where("products.id != #{self.id} and #{Product.is_visible_clause}").
    order("case when product_categories.id = #{self.product_category_id} then 14 else 0 end +
           case when product_categories.parent_id = #{self.product_category.parent_id} then 13 else 0 end +
           case when parent_product_categories.parent_id = #{self.product_category.parent.parent_id} then 12 else 0 end +
           case when product_colors.color_id in (#{self.color_ids.join(',')}) then 6 else 0 end +
           case when product_occasions.occasion_id in (#{self.occasion_ids.blank? ? '0' : self.occasion_ids.join(',')}) then 3 else 0 end +
           case when products.trade_mark_id = #{self.trade_mark_id || 'null'} then 1 else 0 end +
           case when products.merchant_id = #{self.merchant_id} then 1 else 0 end desc,
           products.rating desc").uniq.limit(Conf.product.related_products_count)
  end

  def suitable_products
    Product.joins("join merchants on merchants.id = products.merchant_id
                   join product_pictures on product_pictures.product_id = products.id
                   join outfit_product_pictures on outfit_product_pictures.product_picture_id = product_pictures.id
                   join outfits on outfits.id = outfit_product_pictures.outfit_id
                   join (
                    select outfit_product_pictures.outfit_id as id
                    from outfit_product_pictures
                    join product_pictures on product_pictures.id = outfit_product_pictures.product_picture_id
                    where product_pictures.product_id = #{self.id}
                   ) as product_outfits on product_outfits.id = outfits.id").
    where("products.id != #{self.id} and #{Product.is_visible_clause}").
    order("outfits.rating desc, products.rating desc").uniq.limit(Conf.product.suitable_products_count)
  end

  def outfit_compatible?
    outfit_pictures.present?
  end

private

  def at_least_one_size
    if product_sizes.empty?
      errors.add(:size_ids, "поне един размер трябва да бъде избран")
    end
  end

  def at_least_one_color
    if product_colors.empty?
      errors.add(:color_ids, "поне един цвят трябва да бъде избран")
    end
  end

  def unique_size_category
    if sizes.select(:size_category_id).distinct.count > 1
      errors.add(:size_ids, "размерите трябва да принадлежат към една категория")
    end
  end

  def max_occasions_count
    if product_occasions.size > Conf.occasions.relation_max_count
      errors.add(:occasion_ids, "максимум #{Conf.occasions.relation_max_count} типа облекло могат да бъдат избрани")
    end
  end

  def sync_articles
    # Delete
    destroy_has_errors = false
    articles.where("color_id not in (?) or size_id not in (?)", color_ids, size_ids).each do |d|
       begin
          d.destroy!()
       rescue ActiveRecord::RecordNotDestroyed
          errors.add("article_deletition", "Продукт с цвят #{d.color.name} и размер #{d.size.name} не може да бъде изтрит, тъй като се използва от други обекти в системата.")
          destroy_has_errors = true
       end
    end

    if destroy_has_errors
      return false
    end

    # Insert
    present = articles.where(color_id: color_ids, size_id: size_ids).pluck(:color_id, :size_id)

    color_ids.each do |c|
      size_ids.each do |s|
        if !present.index([c, s])
          if base_price.blank?
            errors.add(:base_price, "При задаване на нови цветове или размери базовата цена трябва да е попълнена.")
            return false
          end
          articles.build(color_id: c, size_id: s, price: base_price)
        end
      end
    end
    true
  end

  def update_url_path
    self.url_path = name.parameterize
    true
  end

  def clear_cache
    if did_attr_change?(:description)
      Modules::OpenGraph.clear_cached_pages(self)
    end
  end

  def reload_product_cache
    Modules::ProductJsonBuilder.instance.refresh_product_cache(id)
  end

  def update_es_outfut_indexes
    Outfit.with_product(id).each do |outfit|
      Modules::DelayedJobs::EsIndexer.schedule('update_document', outfit)
    end
  end

  def update_es_indexes_on_destroy
    update_es_outfut_indexes
  end

  def update_es_indexes_on_save
    if did_attr_change?(:product_category_id) || did_attr_change?(:trade_mark_id)
      self.reload
      update_es_outfut_indexes
    end
  end

  def update_product_category_status
    product_category.update_status
  end

  def update_product_category_status_on_update
    if did_attr_change?(:product_category_id) || did_attr_change?(:status)
      product_category.update_status # New product category value
      if did_attr_change?(:product_category_id)
        old_category_id = self.previous_changes[:product_category_id].first
        ProductCategory.find_by_id(old_category_id).update_status
      end
    end
  end

end

Modules::ElasticSearchHelper.setup_elastic_search_indexes(Product) if Rails.env.development?
