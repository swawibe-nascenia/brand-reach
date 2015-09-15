Rails.application.routes.draw do

  devise_for :users, :controllers => { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'users/registrations' }
    # get 'users/profile' => 'users/registrations#edit_user_profile'

  resources :profile, only: [:update] do
      member do
        get :profile
      end
  end

  resources :public, only: [] do
    collection do
      get :home
      get :brand_home
      get :dashboard
    end
  end

  root to: 'public#home', as: :root
end
