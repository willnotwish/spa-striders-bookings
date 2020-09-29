require 'rails_helper'

RSpec.describe "Admin::Ballots", type: :request do

  describe "GET /index" do
    it "returns http success" do
      get "/admin/ballots/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/ballots/show"
      expect(response).to have_http_status(:success)
    end
  end

end
