require "rails_helper"

RSpec.describe Ballots::NotificationsMailer, type: :mailer do
  describe "success" do
    let(:mail) { Ballots::NotificationsMailer.success }

    it "renders the headers" do
      expect(mail.subject).to eq("Success")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "failure" do
    let(:mail) { Ballots::NotificationsMailer.failure }

    it "renders the headers" do
      expect(mail.subject).to eq("Failure")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
