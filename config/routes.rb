Rails.application.routes.draw do

  devise_for :users, :controllers => { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'users/registrations' }
    # get 'users/profile' => 'users/registrations#edit_user_profile'

  resources :profile, only: [:update] do
      member do
        get :profile
      end
  end
  root to: 'influencers_home#index'

  resources :brands_home, :influencers_home do

  end

end
