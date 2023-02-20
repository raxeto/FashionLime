class Admin::EmailPromotionsController < AdminController

  before_filter :load_subscriber_emails

public

  def index
  end

  def send_promotion
    @title = params[:title]
    @test_email = params[:test_email]
    @message_html = params[:message_html]
    @message_text = params[:message_text]
    @campaign = params[:campaign]

    @query_params = { 
      :utm_source => "newsletter",
      :utm_medium => "email",
      :utm_campaign => @campaign
    }

    # Should be comma separated. Example "1, 2, 4"    
    @product_collection_ids = params[:product_collection_ids]
    @outfit_ids = params[:outfit_ids]
    @product_ids = params[:product_ids]

    if @title.blank? || @campaign.blank? || (@product_collection_ids.blank? && @outfit_ids.blank? && @product_ids.blank?)
      flash.now[:alert] = "Моля попълнете заглавието, кампанията и част от обектите в имейла!"
      render :index
      return
    end

    if @test_email.blank?
      emails_list = @emails
    else
      emails_list = [ @test_email ]
    end

    emails_list.each do |email|
      encrypted_email = ActiveSupport::MessageEncryptor.new(Conf.email_promotions.hash_secret).encrypt_and_sign(email)
      unsubscribe_url = unsubscribe_from_email_promotions_url(email_key: encrypted_email)
      PromotionMailer.promotion_email(email, @title, @message_html, @message_text, @product_collection_ids, @outfit_ids, @product_ids, @query_params, unsubscribe_url).deliver_now
    end

    redirect_to admin_email_promotions_index_path, notice: "#{emails_list.size} email(s) sent."
  end

protected

  def load_subscriber_emails
    @emails = (User.subscribed_for_promotions.pluck(:email) + NewsletterSubscriber.subscribed.pluck(:email)).uniq
  end

end
