module Admin
  class ApplicationController < ::ApplicationController
    before_action :require_admin!

    private

    def require_admin!
      forbidden unless current_user.admin?
    end
  end
end