Rails.application.routes.draw do

  get 'helps/index'

  devise_for :users, :controllers => { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'registrations',
                                       sessions: 'sessions', passwords: 'passwords' }

  resources :profile, path: '', only: [:update] do
    member do
      get :show_user
    end

    collection do
      put :update_password
      get :profile
      get :subregion_options
      post :edit_profile_picture
      post :crop_profile_picture
      post :update_accounts
      get '/contact-us', to: 'profile#contact_us'
      get '/settings', to: 'profile#show_settings'
      get :toggle_available
      post :deactivate_account
      post :update_profile_settings
      post :contact_us_save
      get :verify_brand_profile
    end
  end

  resources :public, path: '', only: [] do
    collection do
      get '/influencers', to: 'public#home', as: 'influencer_home'
      get '/brands', to: 'public#brand_home', as: 'brand_home'
      get :dashboard
      post :get_in_touch
      get :faqs
      get :terms
      get 'sign-up-requirements', to:  'public#sign_up_requirements'
    end
  end

  resources :facebook, only: [:insights] do
    collection do
      get :insights
    end
  end

  # named route for existing working code
  get '/search', to: 'influencers#search', as: 'search_influencers'

  resources :influencers, only: [:show] do
    collection do
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
      get :load_offer
    end
  end

  resources :campaigns, only: [:index, :new, :create, :show] do
    collection do
      # get :campaigns
      # get :brand_campaign
      post :update_activity
      post :campaign_status_change
      get :export
      get :new_brand_payment
      patch :create_brand_payment
      post :confirm_brand_payment
    end
    member do
    end
  end

  resources :payments, only: [:index] do
    collection do
      get :export
      post :withdraw
    end
  end

  resources :bank_accounts, path:'bank-accounts', only: [:new, :create, :destroy] do
    collection do
    end
  end

  get '/explore', to: 'explores#show', as: 'explores'

  get '/admin', to: 'admin/admins#log_in'

  namespace 'admin', path:'' do
    resources :admins, only: [:new, :update, :create, :destroy] do
      collection do
        get 'brands-request', to: 'admins#brands_request'
        get :profile
        get '/manage-admins', to: 'admins#manage_admins'
        get :influencer_list
        get :brand_list
      end

      member do
        put :activate_user
        put :deactivate_user
      end
    end

    resources :invitations do
      collection do
        get :brand_invitation
        post :create_brand_invitation
      end

      member do
        get :resend
      end
    end
  end

  resources :images, only: [:show, :create, :destroy]

  # root to: 'public#home', as: :root
  authenticated :user do
    root to: 'profile#profile', as: :authenticated_root
  end

  unauthenticated do
    root to: 'public#home'
  end
end
