Rails.application.routes.draw do
  get 'home/index'
  get 'login', to: redirect('/users/login-xxx')

  resources :bookings

  root to: 'home#index'
end
