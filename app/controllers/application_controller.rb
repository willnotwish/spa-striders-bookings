require 'application_responder'

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder

  respond_to :html

  include Pundit
  include UserAuthentication

  # prepend_before_action :ensure_test_user!
  # prepend_before_action :examine_session_cookie

  def forbidden
    head :forbidden
  end

  private

  def ensure_test_user!
    logger.warn "ensure_test_user! Use only during development..."
    steve = User.find_or_create_by!(email: 'test@example.com', members_user_id: 1) do |u|
      u.first_name = 'Steve'
      u.last_name = 'Runner'
    end
    session[:user_id] = steve.id
  end

  def examine_session_cookie
    logger.debug "Cookies: #{cookies}"
    logger.debug "_app_session cookie: #{cookies['_app_session']}"
    logger.debug "HTTP session: #{session.inspect}"
    logger.debug "Secret key base: #{Rails.application.secrets.secret_key_base}"
    logger.debug "user_id: #{session[:user_id]}"
  end
end
