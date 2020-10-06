module UserAuthentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :user_logged_in?
    before_action :authenticate_user!
  end
  
  private

  def authenticate_user!
    warden.authenticate!
  end

  def current_user
    @current_user ||= warden.authenticate
  end

  def user_logged_in?
    !!current_user
  end

  def warden
    request.env['warden']
  end
end

# Leave for a while as a reminder. This is how devise does it.

# def authenticate_#{mapping}!(opts={})
#   opts[:scope] = :#{mapping}
#   warden.authenticate!(opts) if !devise_controller? || opts.delete(:force)
# end

# def #{mapping}_signed_in?
#   !!current_#{mapping}
# end

# def current_#{mapping}
#   @current_#{mapping} ||= warden.authenticate(scope: :#{mapping})
# end

# def #{mapping}_session
#   current_#{mapping} && warden.session(:#{mapping})
# end
