Rails.application.routes.draw do
  direct :logout do
    Rails.application.secrets.members_logout_path
  end

  scope '/book' do
    get 'home/index'
    get 'login', to: redirect(Rails.application.secrets.members_login_path)
    
    resources :bookings, except: %i[new create] do
      # Note the module 'booking'. This namespaces only the controller.
      # Do this because the corresponding model is Booking::Confirmation.
      # Makes the controllers easier to write (I hope)
      with_options module: :bookings, only: %i[new create] do
        resources :cancellations
        resources :confirmations
        # resources :reinstatements
      end
      # Shortcuts which look better in the browser
      get 'cancel'  => 'booking/cancellations#new'
      get 'confirm' => 'booking/confirmations#new'
      # get 'reinstate' => 'booking/reinstatements#new'
    end

    resources :events, only: :show
    resources :self_service_bookings, only: %i[new create], path: 'self-service-bookings'

    namespace :terms do
      resource :acceptance, only: %i[new create show]
      get 'accept', to: 'acceptances#new'
    end
    resource :terms, only: :show
    resource :privacy, only: :show, controller: :privacy_policy
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

        resources :attendance_updates, only: %i[new create]

        resources :ballots, shallow: true do
          with_options module: :ballots, only: %i[new create] do
            resources :draws
            resources :opens
            resources :closes
          end
        end
      end

      resources :ballots, only: :index
      resources :users, only: %i[index show edit update]
      resource :dashboard, only: :show
      
      root to: 'dashboard#show'
    end

    root to: 'home#index'
  end
end
