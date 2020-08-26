NEW_AND_CREATE = %i[new create]

Rails.application.routes.draw do
  get 'home/index'
  get 'login', to: redirect('/users/login-xxx')

  resources :bookings, except: NEW_AND_CREATE do
    resources :cancellations, only: NEW_AND_CREATE
  end

  resources :self_service_bookings, only: NEW_AND_CREATE, path: 'self-service-bookings'

  namespace :admin do
    resources :events do

      # Note the module 'event'. This namespaces only the controller.
      # Do this because the corresponding model is Admin::Event::Publication.
      # Makes the controllers easier to write (I hope)
      with_options module: :event, only: NEW_AND_CREATE do
        resources :publications
        resources :restrictions
        resources :locks
      end

      # Shortcuts which look better in the browser
      get 'publish'  => 'event/publications#new'
      get 'restrict' => 'event/restrictions#new'
      get 'lock'     => 'event/locks#new'

      resources :bookings do
        resources :cancellations, shallow: true
      end
    end

    resources :users, only: %i[index show]

    resource :dashboard, only: :show
    root to: 'dashboard#show'
  end

  root to: 'home#index'
end
