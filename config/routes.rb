Rails.application.routes.draw do
  direct :logout do
    '/logout'
  end

  scope '/book' do
    get 'home/index'
    get 'login', to: redirect('/login') # redirect to members app
    
    resources :bookings, except: %i[new create] do
      resources :cancellations, only: %i[new create]
    end

    resources :self_service_bookings, only: %i[new create], path: 'self-service-bookings'

    namespace :admin do
      resources :events do

        # Note the module 'event'. This namespaces only the controller.
        # Do this because the corresponding model is Admin::Event::Publication.
        # Makes the controllers easier to write (I hope)
        with_options module: :event, only: %i[new create] do
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
end
