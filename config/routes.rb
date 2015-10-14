Rails.application.routes.draw do


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
      # get :show_profile
    end
  end

  resources :offers do
    collection do
      put :toggle_star
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
      post :export_campaigns
      get :new_brand_payment
      patch :create_brand_payment
    end
    member do
    end
  end

  resources :brand_payments, only: [] do
    collection do
      get :brand_payment
      post :export_payments
    end
  end

  resources :influencer_payments, only: [] do
    collection do
      get :influencer_payment
      post :export_payments
    end
  end

  resources :bank_accounts, only: [:new, :create, :destroy] do
    collection do
    end
  end

  resource :explores, only: [:show]
  root to: 'public#home', as: :root
end
