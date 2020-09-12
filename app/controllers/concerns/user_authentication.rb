module UserAuthentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :user_logged_in?

    before_action :authenticate_user!
  end
  
  private

  def authenticate_user!
    logger.debug "authenticate_user! About to call warden.authenticate!"
    warden.authenticate!
  end

  def current_user
    @current_user ||= begin
      logger.debug "authenticate_user About to call warden.authenticate"
      warden.authenticate
    end
  end

  def user_logged_in?
    !!current_user
  end

  # def user_session
  #   current_user && warden.session(:user)
  # end

  def warden
    request.env['warden'].tap do |w|
      logger.debug "Warden: #{w}"
    end
  end
end

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
