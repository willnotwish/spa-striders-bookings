require 'rails_helper'

RSpec.describe "Admin::EventRestrictions", type: :request do

  describe "GET /new" do
    it "returns http success" do
      get "/admin/event_restrictions/new"
      expect(response).to have_http_status(:success)
    end
  end

end
