module Admin
  class UsersController < ApplicationController
    respond_to :html
    
    def index
      @users = base_scope.order(last_name: :asc)
      respond_with :admin, @users
    end

    def show
      @user = base_scope.find params[:id]
      respond_with :admin, @user
    end

    private

    def base_scope
      policy_scope(User)
    end
  end
end
