require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { subject }

  it { is_expected.not_to be_nil }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:members_user_id) }
  it { is_expected.to validate_uniqueness_of(:members_user_id) }
  it { is_expected.to have_many(:bookings) }
  it { is_expected.to have_many(:events).through(:bookings) }
  it { is_expected.to have_many(:provisional_bookings) }
  it { is_expected.to have_many(:event_entries) }
  it { is_expected.to have_one(:contact_number) }
  
  it { is_expected.not_to be_admin }
  it { is_expected.not_to have_accepted_terms }

  context 'when the admin flag is true' do
    before do
      user.admin = true
    end

    it { is_expected.to be_admin }
  end

  describe 'guest or member' do
    it { is_expected.not_to be_guest }
    it { is_expected.not_to be_member }

    context "when user's guest period started yesterday" do
      before do
        user.update(guest_period_started_at: 1.day.ago)
      end

      it { is_expected.to be_guest }
      it { is_expected.not_to be_member }  
    end

    context "when user's guest period started 5 weeks ago" do
      before do
        user.update(guest_period_started_at: 5.weeks.ago)
      end

      it { is_expected.not_to be_guest }
      it { is_expected.not_to be_member }  
    end

    context 'when updated to "member"' do
      before do
        user.update(status: :member)
      end
      it { is_expected.not_to be_guest }
      it { is_expected.to be_member }  
    end
  end

  it 'has no phone number' do
    expect(user.phone).to be_blank
  end
  
  it { is_expected.to delegate_method(:phone).to(:contact_number).allow_nil }
end
