Rails.application.routes.draw do


  get 'helps/index'

  devise_for :users, :controllers => { omniauth_callbacks: 'users/omniauth_callbacks'}
  # get 'users/profile' => 'users/registrations#edit_user_profile'

  # map.connect '/:profile', controller: 'profile', action: 'profile'

  resources :profile, path: '', only: [:update] do
    member do
    end

    collection do
      put :update_password
      get :profile
      get :subregion_options
      post :edit_profile_picture
      post :update_accounts
      get :contact_us
      get :show_settings
      get :toggle_available
      post :deactivate_account
      post :update_profile_settings
      post :contact_us_save
    end
  end

  resources :public, only: [] do
    collection do
      get :home
      get :brand_home
      get :dashboard
      post :get_in_touch
    end
  end

  resources :facebook do
    collection do
      get :insights
    end
  end

  resources :influencers, only: [:show] do
    collection do
      get :search
    end
  end

  resources :offers do
    collection do
      put :toggle_star
      put :delete_offers
    end

    member do
      put :accept
      put :deny
      put :undo_deny
      post :reply_message
      post :make_messages_read
    end
  end

  resources :campaigns, only: [:new, :create, :show] do
    collection do
      get :influencer_campaign
      get :brand_campaign
      post :campaign_status_change
      get :export_influencer_campaigns
      get :export_brand_campaigns
      post :new_brand_payment
      patch :create_brand_payment
    end
    member do
    end
  end

  resources :brand_payments, path: 'payments', only: [] do
    collection do
      get :brand_payment
      post :export_payments
    end
  end

  resources :influencer_payments, path: 'payments', only: [:index] do
    collection do
      post :export_payments
      post :withdraw_payment
    end
  end

  resources :bank_accounts, only: [:new, :create, :destroy] do
    collection do
    end
  end

  resource :explores, only: [:show]
  # root to: 'public#home', as: :root
  authenticated :user do
    root to: 'profile#profile', as: :authenticated_root
  end

  unauthenticated do
    root to: 'public#home'
  end
end
