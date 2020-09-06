Rails.application.routes.draw do
  direct :logout do
    Rails.application.secrets.members_logout_path
  end

  scope '/book' do
    get 'home/index'
    get 'login', to: redirect(Rails.application.secrets.members_login_path)
    
    resources :bookings, except: %i[new create] do
      resources :cancellations, only: %i[new create]
    end

    resources :self_service_bookings, only: %i[new create], path: 'self-service-bookings'

    namespace :terms do
      resource :acceptance, only: %i[new create show]
      get 'accept', to: 'acceptances#new'
    end
    resource :terms, only: :show
    resource :privacy, only: :show, controller: :privacy_policy

    resources :events, only: :show

    resource :contact_number, path: 'contact-number', except: :destroy

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
