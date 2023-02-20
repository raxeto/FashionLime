Rails.application.routes.draw do

  root to: 'home#index'

  controller :application do
    get 'ping' => :ping, as: 'ping'
  end

  # Error pages
  %w( 404 422 500 ).each do |code|
    get code, :to => "errors#show", :code => code
  end

  # It's important this controller to be before products & outfits controllers
  controller :search_page do
    get 'produkti/s/:search_phrase' => :product_page, as: 'products_search_page'
    get 'produkti/s/:search_phrase/load_more_products' => :product_page_load_more, as: 'products_search_page_load_more'
    get 'vizii/s/:search_phrase' => :outfit_page, as: 'outfits_search_page'
    get 'vizii/s/:search_phrase/load_more_outfits' => :outfit_page_load_more, as: 'outfits_search_page_load_more'
  end

  devise_for :users, controllers: { sessions: 'sessions', registrations: 'registrations', passwords: 'passwords' }
  devise_scope :user do
    post  'users/deactivate', :to => 'registrations#deactivate'
    patch 'users/update_profile', :to => 'registrations#update_profile'
    get   'users/edit_password', :to => 'passwords#edit_password'
    patch 'users/update_password', :to => 'passwords#update_password'
  end

  controller :carts, only: [:show] do
    get 'cart/show' => :show
    delete 'cart/destroy_item' => :destroy_item
    patch 'cart/update' => :update_cart_details
  end

  controller :search do
    get  'search/generic' => :search, as: 'generic_search'
  end

  controller :favorites do
    get  'favorites' => :index, as: 'favorites_index'
  end

  controller :legal do
    get 'terms-of-use'   => :terms_of_use
    get 'cookies-policy' => :cookies_policy
    get 'privacy-policy' => :privacy_policy
  end

  resources :orders, only: [:index, :new, :create]

  controller :orders do
    get  'orders/payment/:first_order_number' => :additional_payment_step, as: 'show_additional_payment_step'
    get  'orders/return-request'    => :new_return, as: 'new_return_order'
    post 'orders/return-request'    => :create_return, as: 'create_return_order'
    get  'orders/epay_code'         => :get_epay_code, as: "get_epay_code"
    get  'orders/:number'           => :show, as: "order"
    get  'orders/thanks/:number'    => :thank_you, as: "thank_you"
  end

  controller :campaigns do
    get  'c/:campaign/' => :show, as: 'campaign_show'
    get  'c/:campaign_id/load_more_products' => :load_more_products, as: 'campaign_products_load_more'
    get  'c/:campaign_id/load_more_outfits' => :load_more_outfits, as: 'campaign_outfits_load_more'
  end

  controller :profiles do
    get   'm/:url_path' => :show_merchant, as: 'merchant_profile', :constraints => { :url_path => /[^\/]+/ }
    get   'u/:url_path' => :show_user, as: 'user_profile', :constraints => { :url_path => /[^\/]+/ }
    get   'm/:url_path/kolekcii' => :product_collections, as: 'merchant_profile_product_collections', :constraints => { :url_path => /[^\/]+/ }
    get   'm/:url_path/kolekcii/:collection' => :product_collection, as: 'merchant_profile_product_collection', :constraints => { :url_path => /[^\/]+/ }
    get   'm/:url_path/produkti' => :products, as: 'merchant_profile_products', :constraints => { :url_path => /[^\/]+/ }
    get   'm/:url_path/load_more_products' => :load_more_products, as: 'merchant_profile_products_load_more', :constraints => { :url_path => /[^\/]+/ }
    get   'm/:url_path/vizii' => :merchant_outfits, as: 'merchant_profile_outfits', :constraints => { :url_path => /[^\/]+/ }
    get   'm/:url_path/load_more_outfits' => :load_more_merchant_outfits, as: 'merchant_profile_outfits_load_more', :constraints => { :url_path => /[^\/]+/ }
    get   'u/:url_path/vizii' => :user_outfits, as: 'user_profile_outfits', :constraints => { :url_path => /[^\/]+/ }
    get   'u/:url_path/load_more_outfits' => :load_more_user_outfits, as: 'user_profile_outfits_load_more', :constraints => { :url_path => /[^\/]+/ }
    get   'u/:url_path/haresani-produkti' => :user_favorite_products, as: 'user_profile_favorite_products', :constraints => { :url_path => /[^\/]+/ }
    get   'u/:url_path/load_more_favorite_products' => :load_more_user_favorite_products, as: 'user_profile_favorite_products_load_more', :constraints => { :url_path => /[^\/]+/ }
  end

  controller :outfits do
    get  'vizii/' => :show_all, as: 'all_outfits'
    get  'vizii/nova' => :new, as: 'new_outfit'
    post 'vizii/nova' => :create, as: 'create_outfit'
    get  'vizii/load_more_products' => :load_more_products, as: 'load_more_products_outfits'
    get  'vizii/:category_or_product' => :show_category_or_product, as: 'outfits_by_category_or_product_outfits'
    get  'vizii/:category_or_product/:occasion_or_outfit' => :show_outfit_or_occasion, as: 'outfits_by_occasion_or_outfit'
    get  'vizii/load_more_outfits/:category_id/:occasion_id/:product_id' => :load_more_outfits, as: 'outfits_load_more_outfits'
  end

  resources :outfits, only: [:edit, :update, :destroy]  do
    collection do
      get :my_outfits
      get 'pictures_for_product/:product_id' => :pictures_for_product
    end
    member do
      get :add_to_cart, as: 'add_to_cart'
      post :insert_to_cart
      get :picture_present
    end
  end

  controller :ratings do
    post 'ratings/increase'   => :increase
    post 'ratings/decrease'   => :decrease
    post 'ratings/invalidate' => :invalidate
  end

  controller :contact do
    get 'contact' => :new
    post 'contact' => :create
  end

  controller :information do
    get 'about-us' => :about_us
    get 'nov-targovec' => :new_merchant, as: 'information_new_merchant'
    get 'dostavka-plashtane' => :delivery_and_payment, as: 'information_delivery_payment'
    get 'coming-soon' => :coming_soon, as: 'coming_soon'
  end

  controller :email_promotions do
    get 'email_promotions/successfully_unsubscribed' => :successfully_unsubscribed
    get 'email_promotions/unsubscribe/:email_key' => :unsubscribe, as: 'unsubscribe_from_email_promotions'
  end

  controller :newsletter do
    post 'newsletter/subscribe' => "subscribe"
  end

  controller :blog_posts do
    get 'a/:url_path' => :show, as: 'blog_post'
  end

  get 'admin', to: 'admin#index'

  namespace :admin do
    resources :users, only: [:index, :edit] do
      member do
        delete :destroy_avatar
      end
    end
    controller :users do
      get 'users/avatars' => :avatars
    end
    controller :requests do
      get 'request/stats' => :index
    end
    resources :trade_marks
    resources :merchant_product_api_mappings
    resources :colors
    resources :payment_types
    resources :shipment_types
    resources :product_categories
    resources :search_pages
    resources :blog_posts
    resources :outfit_sets
    resources :merchants, only: [:new, :create]
    resources :home_page_variants, only: [:index, :new, :create, :destroy]
    resources :home_page_links
    resources :campaigns, only: [:index, :new, :create, :destroy] do
      member do
        get  :new_outfits
        post :create_outfits
      end
    end
    controller :campaigns do
      get  'admin/campaigns/load_more_products' => :load_more_products, as: 'campaign_load_more_products'
      get  'admin/campaigns/load_more_outfits' => :load_more_outfits, as: 'campaign_load_more_outfits'
    end

    resources :open_graph_tags
    resources :outfit_decorations do 
      collection do
        get  'edit_order_index/:category' => :edit_order_index, as: 'edit_order_index'
        post 'edit_order_index/:category' => :update_order_index, as: 'update_order_index'
      end
    end
    resources :contact_inquiries, only: [:index, :edit, :update] do
      member do
        patch :set_not_valid
      end
    end
    controller :stale_orders do
      get 'orders/index' => :index, as: 'stale_orders'
      get 'orders/index_returns' => :index_returns, as: 'stale_returns'
      get 'orders/show_return/:id' => :show_return, as: 'stale_return'
      get 'orders/show_order/:id' => :show_order, as: 'stale_order'
      post 'orders/confirm_order/:id' => :confirm_order, as: 'stale_confirm_order'
    end

    controller :clip_product_pictures do
      get  'admin/clip_product_pictures/without_outfit_pics' => :show_products_without_outfit_pictures, as: 'clip_pp_without_outfit_pic'
      get  'admin/clip_product_pictures/with_outfit_pics' => :show_products_with_outfit_pictures, as: 'clip_pp_with_outfit_pic'
      post 'admin/clip_product_pictures/generate_zip' => :generate_zip, as: 'generate_pp_zip'
      post 'admin/clip_product_pictures/upload_zip' => :upload_zip, as: 'upload_zip'
    end

    controller :email_promotions do
      get 'email_promotions/index' => :index
      post 'email_promotions/send_promotion' => :send_promotion
    end
  end

  get 'merchant', to: 'merchant#index', as: 'merchant_root'

  namespace :merchant do

    resources :product_collections, only: [:index, :edit, :new, :destroy, :create, :update]

    resources :products, only: [:index, :edit, :new, :destroy, :create, :update] do
      collection do
        get :size_categories_for_product_category
      end
      member do
        get :edit_articles
        get :edit_article_quantities
        get :edit_pictures
        post :add_picture
        post :update_picture_details
        post :delete_picture
        patch :update_articles
        patch :update_article_quantities
        delete :destroy_article_quantity
      end
    end

    controller :products_import do
      get   'products/import' => :index, :as => "import_products"
      post  'products/import' => :preview, :as => "import_products_preview"
      post  'products/import/confirm/' => :confirm, :as => "import_products_confirm"
    end

    controller :product_pictures_import do
      get   'products/import_pictures' => :new, :as => "new_product_pictures_import"
      get   'products/import_pictures/product_info' => :product_info
      post  'products/import_pictures' => :create, :as => "create_product_picture_import"
    end

    controller :orders do
      get   'orders' => :index
      get   'orders/:number/edit' => :edit, :as => "edit_order"
      patch 'orders/:number/edit' => :update
    end

    controller :order_returns do
      get   'order_returns' => :index
      get   'order_returns/:number' => :show, :as => "order_return"
      post  'order_returns/:number/process_returns'   => :process_returns, as: "order_process_returns"
      post  'order_returns/:number/process_exchanges' => :process_exchanges, as: "order_process_exchanges"
      post  'order_returns/:number/mark_returned'     => :mark_returned, as: "order_mark_returned"
    end

    controller :shipments do
      get    'shipments' => :index
      patch  'shipments/update_shipments' => :update_shipments
      delete 'shipments/destroy_item' => :destroy_item
    end

    resources :payment_types, only: [:index, :new, :create, :edit, :update]
    controller :payment_types do
      get    'payment_types/activation' => :new_activation
      post   'payment_types/activation' => :create_activation
    end

    controller :size_charts do
      delete 'size_charts/destroy_item' => :destroy_item
    end
    resources :size_charts, only: [:index, :new, :create, :edit, :update, :destroy]

    controller :merchant do
      get 'edit_merchant' => :edit_merchant
      patch 'update_merchant' => :update_merchant
    end

    controller :activation do
      get 'activation' => :index
    end

    controller :report_views do
      get  'reports/views' => :views, as: 'reports_views'
      post 'reports/views' => :generate_views, as: 'reports_generate_views'
    end

    controller :report_orders do
      get  'reports/orders' => :orders, as: 'reports_orders'
      post 'reports/orders' => :generate_orders, as: 'reports_generate_orders'
    end

    controller :report_carts do
      get  'reports/carts' => :carts, as: 'reports_carts'
      post 'reports/carts' => :generate_carts, as: 'reports_generate_carts'
    end

    controller :contact do
      get 'contact' => :new
      post 'contact' => :create
    end

    devise_scope :user do
      controller :registrations do
        get   'edit' => :edit
        patch 'update_profile' => :update_profile
        get   'profile_users' => :profile_users
        get   'profile_users/new' => :new_profile_user
        post  'profile_users/new' => :create_profile_user, :as => "profile_users_create"
        patch 'profile_users/update' => :update_profile_users
      end

      controller :sessions do
        get 'sessions/new' => :new
        post 'sessions/create' => :create
        delete 'sessions/destroy' => :destroy
      end

      controller :passwords do
        get 'password/edit' => :edit_password
        patch 'password/update' => :update_password
      end
    end

  end

  # It's important that controller actions to be the end of all other routes in order to match last
  controller :products do
    get  'produkti/:category_id/load_more_products' => :load_more_products, as: 'products_by_category_load_more'
    get  'produkti/:id/sizes_for_color'      => :sizes_for_color, as: 'product_sizes_for_color'
    get  'produkti' => :show_all, as: 'all_products'
    get  '/:category' => :show_category, as: 'products_by_category'
    get  '/:category/:subcategory_or_product' => :show_product_or_category, as: 'product_or_subcategory'
    post 'products/:id/add_to_cart'          => :add_to_cart, as: 'product_add_to_cart'
  end

end
