Rails.application.routes.draw do

  devise_for :users, :controllers => { omniauth_callbacks: 'users/omniauth_callbacks', registrations: 'users/registrations' }
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

  root to: 'public#home', as: :root
end
