Rails.application.routes.draw do
  get 'home/index'
  get 'login', to: redirect('/users/login-xxx')

  resources :bookings do
    resources :cancellations, only: %i[new create]
  end

  namespace :admin do
    resources :events do
      resources :bookings do
        resources :cancellations, shallow: true
      end
    end
  end

  root to: 'home#index'
end
