class MerchantEpayInfo < ActiveRecord::Base

  include Modules::MerchantPaymentInfoLib

  require 'net/http'
  require 'net/https'
  require 'uri'
  require 'openssl'
  require 'base64'

  # Attributes
  attr_encrypted :secret, key: :secret_key

  # Associations
  has_one :merchant_payment_type, as: :info
  has_one :merchant, through: :merchant_payment_type

  # Validations
  validates_presence_of :min_code, :secret
  validates_length_of :secret, is: 64
  validate  :has_merchant_order, on: :update

  def text
    "КИН: #{min_code}"
  end

  def old_secret
    s = secret_changed? ? secret_was : secret
    symbols = Conf.payments.epay_secret_visible_symbols
    symbols_from_start = symbols / 2
    symbols_from_end = symbols / 2 + symbols % 2
    asterix_symbols = 64 - symbols
    "#{s[0..symbols_from_start - 1]}#{'*' * asterix_symbols}#{s[-symbols_from_end..-1]}"
  end

  def generate_payment_code(order_id, amount)
    Modules::DelayedJobs::EpayCodeFetcher.get(id, order_id, amount)
    return nil
  end

  def request_payment_code(order_id, amount)
    request = build_request(order_id, amount)
    encoded_request = encode_bill_request(request)
    params = {
      ENCODED: encoded_request,
      CHECKSUM:  OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'),
          secret.encode("ASCII"), encoded_request.to_s.encode("ASCII"))
    }
    send_payment_code_request(params, request)
  end

  def secret_key
    key = Rails.application.secrets.epay_secret_key
    if Rails.env.production?
      raise 'Secret key for merchant epay info must be set!!!' unless key
      key
    else
      key || 'oHs6wkkZU00NS8TT9EtFC0BHojdzxGbcahJEi9HOvFw='
    end
  end

  protected

  def build_request(order_id, amount)
    request = "AMOUNT=#{amount}\n"
    request += "DESCR=Покупка във FashionLime\n"
    request += "EXP_TIME=#{generate_exp_time}\n"
    request += "INVOICE=#{order_id}\n"
    request += "MIN=#{min_code}"
    return request
  end

  def encode_bill_request(request)
    Base64.encode64(request)
  end

  def generate_exp_time
    exp_date = Time.now + Conf.payments.epay_exp_date_offset
    exp_date.strftime("%d.%m.%Y")
  end

  def send_payment_code_request(params, request_data)
    url = Rails.configuration.payments[:epay_url] + '/ezp/reg_bill.cgi'

    begin
      uri = URI.parse(url)
      uri.query = URI.encode_www_form(params)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri.to_s)

      response = http.request(request)
      response.body.try(:strip)
    rescue => e
      Rails.logger.error e.message
      nil
    end
  end

end
