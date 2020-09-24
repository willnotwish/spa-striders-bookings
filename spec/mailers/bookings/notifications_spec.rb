require "rails_helper"

RSpec.describe Bookings::NotificationsMailer, type: :mailer do
  describe "cancelled" do
    let(:mail) { Bookings::NotificationsMailer.cancelled }

    it "renders the headers" do
      expect(mail.subject).to eq("Cancelled")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "confirmed" do
    let(:mail) { Bookings::NotificationsMailer.confirmed }

    it "renders the headers" do
      expect(mail.subject).to eq("Confirmed")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "provisional" do
    let(:mail) { Bookings::NotificationsMailer.provisional }

    it "renders the headers" do
      expect(mail.subject).to eq("Provisional")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
