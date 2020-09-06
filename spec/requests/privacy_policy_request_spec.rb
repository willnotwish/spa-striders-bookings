require 'rails_helper'

RSpec.describe "PrivacyPolicies", type: :request do

  describe "GET /show" do
    it "returns http success" do
      get "/privacy_policy/show"
      expect(response).to have_http_status(:success)
    end
  end

end
