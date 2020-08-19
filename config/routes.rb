Rails.application.routes.draw do
  get 'home/index'
  get 'login', to: redirect('/users/login-xxx')

  root to: 'home#index'
end
