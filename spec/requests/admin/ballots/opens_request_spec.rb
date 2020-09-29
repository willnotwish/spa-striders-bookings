require 'rails_helper'

RSpec.describe "Admin::Ballots::Opens", type: :request do

  describe "GET /new" do
    it "returns http success" do
      get "/admin/ballots/opens/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/admin/ballots/opens/create"
      expect(response).to have_http_status(:success)
    end
  end

end
