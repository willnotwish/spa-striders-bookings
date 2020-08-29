require 'rails_helper'

RSpec.describe "SelfServiceBookings", type: :request do

  describe "GET /new" do
    it "returns http success" do
      get "/self_service_bookings/new"
      expect(response).to have_http_status(:success)
    end
  end

end
