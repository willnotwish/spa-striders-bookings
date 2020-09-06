module Terms
  class AcceptancesController < ApplicationController  
    def new
    end

    def create
      current_user.update(accepted_terms_at: Time.now)
      respond_with current_user, notice: I18n.t(:terms_accepted), location: :root
    end

    def show
    end
  end
end
