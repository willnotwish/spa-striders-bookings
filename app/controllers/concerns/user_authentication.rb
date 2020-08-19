module UserAuthentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :user_logged_in?

    before_action :authenticate_user!
  end
  
  private

  def authenticate_user!
    redirect_to :login if session[:user_id].blank?
  end

  def current_user
    @current_user ||= User.find_by!(members_user_id: session[:user_id])
  end

  def user_logged_in?
    !current_user.nil?
  end
end
