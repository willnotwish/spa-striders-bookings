require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder

  respond_to :html

  include Pundit
  include UserAuthentication

  prepend_before_action :ensure_test_user!

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
end
