class HomeController < ApplicationController
  helper_method :current_user

  def index
    authenticate_user!
  end

  private

  def authenticate_user!
    if session[:user_id].blank?
      redirect_to :login
    end
  end

  def current_user
    @current_user ||= User.find_by!(members_user_id: session[:user_id])
  end
end
