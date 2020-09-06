require 'rails_helper'

RSpec.describe "Terms::Acceptances", type: :request do

  describe "GET /new" do
    it "returns http success" do
      get "/terms/acceptances/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/terms/acceptances/show"
      expect(response).to have_http_status(:success)
    end
  end

end
