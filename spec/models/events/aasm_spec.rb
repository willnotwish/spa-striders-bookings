require 'rails_helper'

module Events
  RSpec.describe 'aasm behaviour', type: :model do
    subject { FactoryBot.create :event, aasm_state: :draft }

    let(:admin) { FactoryBot.create :user, admin: true }
    let(:regular_user) { FactoryBot.create :user }
    let(:hills) { subject }

    it { is_expected.to be_draft }
    it { is_expected.not_to be_published }
    # it { is_expected.not_to allow_event(:populate) }

    # it 'may not fire :populate with an admin as parameter' do
    #   expect(hills.may_populate?(user: admin)).to be_falsy
    # end

    # it 'when an admin opens the ballot its persisted state changes to opened' do
    #   expect { ballot.open(user: admin) }.to change { ballot.aasm_state }.to('opened')
    # end

    # describe 'opening permissions' do
    #   let(:steve_runner) { FactoryBot.create :user }

    #   it 'an admin may open the ballot' do
    #     expect(ballot.may_open?(user: admin)).to eq(true)
    #   end

    #   it 'Steve Runner may not open the ballot' do
    #     expect(ballot.may_open?(user: steve_runner)).to eq(false)
    #   end

    #   it 'an anonymous user may not open the ballot' do
    #     expect(ballot.may_open?(user: nil)).to eq(false)
    #   end

    #   it "making steve runner an event admin for hills means that he is able to open the ballot" do
    #     expect do 
    #       FactoryBot.create(:event_admin, user: steve_runner, event: hills)
    #     end.to change { ballot.may_open?(user: steve_runner) }.from(false).to(true)
    #   end
    # end

    # context 'when opened by an admin' do
    #   before do
    #     ballot.open(user: admin)
    #   end

    #   it { is_expected.to be_opened }
    #   it { is_expected.not_to allow_event(:draw) }
    # end

    # it 'locking the event allows the ballot to be drawn by an admin' do
    #   expect { hills.lock(user: admin) }.to change { ballot.may_draw?(user: admin) }.from(false).to(true)
    # end

    # it 'locking the event does not allow the ballot to be drawn by a regular user' do
    #   expect { hills.lock(user: admin) }.not_to change { ballot.may_draw?(user: regular_user) }
    # end

    # context 'after the event is locked by an admin' do
    #   before do
    #     hills.lock!(user: admin)
    #     # expect(ballot).to be_closed
    #   end

    #   it 'can be populated by an admin' do
    #     expect(hills.may_populate?(user: admin)).to eq(true)
    #   end

    #   it 'cannot be populated by a regular user' do
    #     expect(hills.may_populate?(user: regular_user)).to eq(false)
    #   end

    #   it 'expects an AASM::InvalidTransition exception to be raised when a regular user attempts to draw' do
    #     expect { hills.populate(user: regular_user) }.to raise_error(AASM::InvalidTransition)
    #   end

    #   it 'populating the event without a bang does not change its state' do
    #     expect { hills.populate(user: admin) }.not_to change { hills.aasm.current_state }
    #   end

    #   it '#populate returns true' do
    #     expect(hills.populate(user: admin)).to eq(true)
    #   end

    #   it 'populating an empty event does change the number of bookings' do
    #     expect { hills.populate!(user: admin) }.not_to change { Booking.count }
    #   end

    #   context 'when three users (Steve, Ann & Roger) have event entries, populating the event' do
    #     let(:steve) { FactoryBot.create :user, first_name: 'Steve' }
    #     let(:ann)   { FactoryBot.create :user, first_name: 'Ann'   }
    #     let(:roger) { FactoryBot.create :user, first_name: 'Roger' }

    #     let(:populate) { hills.populate(user: admin) }
    #     let(:populate!) { hills.populate!(user: admin) }

    #     before do
    #       [steve, ann, roger].each do |user|
    #         FactoryBot.create :event_entry, event: hills, user: user
    #       end
    #       expect(hills).to have(3).entries
    #       expect(hills.capacity > 3).to eq(true)
    #       expect(hills.participants.count).to eq(0)
    #       expect(hills.may_populate?(user: admin)).to eq(true)
    #     end
        
    #     it 'without a bang creates no new provisional bookings' do
    #       expect { populate }.not_to change { Booking.provisional.count }
    #     end

    #     it 'with a bang creates three provisional bookings' do
    #       expect { hills.populate!(user: admin) }.to change { Booking.count }.by(3)
    #     end

    #     it 'without a bang and then explicitly saving the event creates three provisional bookings' do
    #       expect { populate; hills.save }.to change { Booking.provisional.count }.by(3)
    #     end

    #     it 'creates no new confirmed bookings' do
    #       expect { populate! }.not_to change { Booking.confirmed.count }
    #     end

    #     it "assigns a provisional booking to Steve" do
    #       expect { populate! }.to change { steve.bookings.provisional.count }.by(1)  
    #     end

    #     it "assigns a provisional booking to Ann" do
    #       expect { populate! }.to change { ann.bookings.provisional.count }.by(1)  
    #     end

    #     it "assigns a provisional booking to Roger" do
    #       expect { populate! }.to change { roger.bookings.provisional.count }.by(1)  
    #     end

    #     it "changes the booking in Steve's entry entry from nil" do
    #       expect { populate! }.to change { steve.event_entries.where(event: hills).first.booking }.from(nil)  
    #     end

    #     context 'with a bookings collector as an array option' do
    #       let(:collector) { [] }

    #       before do
    #         hills.populate(user: admin, bookings_collector: collector)
    #       end

    #       it 'drawing the ballot populates the array with three bookings' do
    #         expect(collector).to have(3).items
    #       end
    #     end

    #     context 'when the ballot is drawn by an admin' do
    #       before do
    #         draw_ballot!(admin)
    #       end

    #       it 'the ballot has three successful entries' do
    #         expect(ballot.successful_entries).to have(3).items
    #       end

    #       it 'the ballot has no unsuccessful entries' do
    #         expect(ballot.unsuccessful_entries).to be_empty
    #       end
    #     end

    #     context 'when Steve already has a confirmed booking' do
    #       before do
    #         FactoryBot.create(:booking, aasm_state: :confirmed, user: steve, event: hills)
    #         expect(steve).to have(1).confirmed_booking
    #       end

    #       it 'drawing the ballot creates two new provisional bookings' do
    #         expect { draw_ballot!(admin) }.to change { Booking.provisional.count }.by(2)
    #       end
    #     end

    #     context 'when Steve already has a provisional booking' do
    #       before do
    #         FactoryBot.create(:booking, aasm_state: :provisional, user: steve, event: hills)
    #         expect(steve).to have(1).provisional_booking
    #       end

    #       it 'drawing the ballot with a bang creates two new provisional bookings' do
    #         expect { draw_ballot!(admin) }.to change { Booking.provisional.count }.by(2)
    #       end
    #     end

    #     context 'when Ann (somehow) has two ballot entries' do
    #       before do
    #         entry = FactoryBot.build :ballot_entry, ballot: ballot, user: ann
    #         entry.save(validate: false)
    #         expect(ann).to have(2).ballot_entries
    #       end

    #       it 'the ballot cannot be drawn' do
    #         expect(ballot.may_draw?(user: admin)).to be_falsy
    #       end
    #     end
    #   end
    # end
  end
end
 