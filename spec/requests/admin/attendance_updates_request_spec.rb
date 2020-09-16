require 'rails_helper'

RSpec.describe "Admin::AttendanceUpdates", type: :request do

  describe "GET /new" do
    it "returns http success" do
      get "/admin/attendance_updates/new"
      expect(response).to have_http_status(:success)
    end
  end

end
