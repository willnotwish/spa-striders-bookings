require 'rails_helper'

RSpec.describe Bookings::Cancellation, type: :model do
  let(:steve_runner) { FactoryBot.create(:user) }
  let(:hills) { FactoryBot.create(:event, starts_at: 1.week.from_now) }
  let(:booking) do
    FactoryBot.create(:booking, aasm_state: :confirmed, event: hills, user: steve_runner)
  end

  let(:cancellation) { subject }

  before do
    subject.booking = booking
  end

  it { is_expected.to validate_presence_of(:booking) }

  context 'for hills next week' do
    context 'when the current user is Steve Runner' do
      before do
        subject.current_user = steve_runner
      end

      it { is_expected.to be_valid }
    end

    context 'when the current user is an admin' do
      let(:admin) { FactoryBot.create(:user, admin: true) }

      before do
        subject.current_user = admin
      end

      it { is_expected.to be_valid }
    end

    context 'when the current user is Alice - another regular member' do
      let(:alice) { FactoryBot.create :user }

      before do
        subject.current_user = alice
      end

      it { is_expected.to be_invalid }
    end

    context 'when the current user is Doug - an event admin' do
      let(:doug) do 
        FactoryBot.create(:user).tap do |user|
          FactoryBot.create :event_admin, user: user, event: hills
        end
      end

      before do
        subject.current_user = doug
      end

      it { is_expected.to be_valid }
    end

    context 'when the owner is cancelling' do
      before do
        subject.current_user = booking.user
      end
      
      it { is_expected.to be_valid }

      it '#save returns truthy' do
        expect(cancellation.save).to be_truthy
      end
  
      it "saving changes the booking state from confirmed to cancelled" do
        expect { cancellation.save }.to change { booking.aasm_state }.from('confirmed').to('cancelled')
      end
  
      it "saving cancels the booking" do
        expect { cancellation.save }.to change { booking.cancelled? }.from(false).to(true)
      end
  
      it "saving changes the number of booking transitions by 1" do
        expect { cancellation.save }.to change { booking.transitions.count }.by(1)
      end
  
      it "saving changes the number of sent emails by 1" do
        expect { cancellation.save }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end

  context 'for hills yesterday' do
    before do
      hills.update_column(:starts_at, 1.day.ago)
    end

    it { is_expected.to be_invalid }

    it '#save returns false' do
      expect(cancellation.save).to eq(false)
    end

    it "saving does not change the booking state" do
      expect { cancellation.save }.not_to change { booking.aasm_state }
    end

    it "saving does not cancel the booking" do
      expect { cancellation.save }.not_to change { booking.cancelled? }
    end
  end
end
