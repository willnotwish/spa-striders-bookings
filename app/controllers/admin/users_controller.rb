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

    def edit
      @user = base_scope.find params[:id]
      respond_with :admin, @user
    end

    def update
      @user = base_scope.find params[:id]
      @user.update user_params
      respond_with :admin, @user
    end

    private

    def base_scope
      policy_scope(User)
    end

    def user_params
      params.fetch(:user, {}).permit(:admin)
    end
  end
end
