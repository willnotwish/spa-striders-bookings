require 'rails_helper'

module Ballots
  RSpec.describe StateMachine, type: :model do
    subject { described_class.new(ballot) }

    let(:hills) { FactoryBot.create :event }
    let(:ballot) { FactoryBot.create(:ballot, event: hills, aasm_state: :closed) }
    let(:admin) { FactoryBot.create :user, admin: true }
    let(:regular_user) { FactoryBot.create :user }
    let(:state_machine) { subject }

    it { is_expected.to be_closed }
    it { is_expected.not_to be_opened }
    it { is_expected.not_to allow_event(:draw, admin) }

    it 'may not fire :draw with an admin as parameter' do
      expect(state_machine.may_draw?(admin)).to be_falsy
    end

    it 'when an admin opens the ballot its persisted state changes to opened' do
      expect { state_machine.open(admin) }.to change { ballot.aasm_state }.to('opened')
    end

    describe 'opening permissions' do
      let(:steve_runner) { FactoryBot.create :user }

      it 'an admin may open the ballot' do
        expect(state_machine.may_open?(admin)).to eq(true)
      end

      it 'Steve Runner may not open the ballot' do
        expect(state_machine.may_open?(steve_runner)).to eq(false)
      end

      it 'a nil user may not open the ballot' do
        expect(state_machine.may_open?(nil)).to eq(false)
      end

      it 'an anonymous user may not open the ballot' do
        expect(state_machine.may_open?).to eq(false)
      end

      it "making steve runner an event admin for hills means that he is able to open the ballot" do
        expect do 
          FactoryBot.create(:event_admin, user: steve_runner, event: hills)
        end.to change { state_machine.may_open?(steve_runner) }.from(false).to(true)
      end
    end

    context 'when opened by an admin' do
      before do
        state_machine.open(admin)
      end

      it { is_expected.to be_opened }
      it { is_expected.not_to allow_event(:draw) }
    end

    it 'locking the event allows the ballot to be drawn by an admin' do
      expect { hills.lock(admin) }.to change { state_machine.may_draw?(admin) }.from(false).to(true)
    end

    it 'locking the event does not allow the ballot to be drawn by a regular user' do
      expect { hills.lock(admin) }.not_to change { state_machine.may_draw?(regular_user) }
    end

    context 'after the event is locked by an admin' do
      before do
        hills.lock(admin)
      end

      it 'can be drawn by an admin' do
        expect(state_machine.may_draw?(admin)).to eq(true)
      end

      it 'cannot be drawn by a regular user' do
        expect(state_machine.may_draw?(regular_user)).to eq(false)
      end

      it 'drawing the ballot on a locked event changes its persisted state to drawn' do
        expect { state_machine.draw(admin) }.to change { ballot.aasm_state }.to('drawn')
      end

      it '#draw returns true' do
        expect(state_machine.draw(admin)).to eq(true)
      end

      it 'drawing an empty ballot does change the number of bookings' do
        expect { state_machine.draw(admin) }.not_to change { Booking.count }
      end

      context 'when three users (Steve, Ann & Roger) are in the ballot' do
        let(:steve) { FactoryBot.create :user, first_name: 'Steve' }
        let(:ann)   { FactoryBot.create :user, first_name: 'Ann'   }
        let(:roger) { FactoryBot.create :user, first_name: 'Roger' }

        before do
          [steve, ann, roger].each do |user|
            FactoryBot.create :ballot_entry, ballot: ballot, user: user
          end
          expect(ballot).to have(3).ballot_entries
        end

        it 'drawing the ballot creates three provisional bookings' do
          expect { state_machine.draw(admin) }.to change { Booking.provisional.count }.by(3)
        end

        it 'drawing the ballot sends three emails' do
          expect { state_machine.draw(admin) }.to change { ActionMailer::Base.deliveries.length }.by(3)
        end

        it 'drawing the ballot creates no new confirmed bookings' do
          expect { state_machine.draw(admin) }.not_to change { Booking.confirmed.count }
        end

        it "drawing the ballot assigns a provisional booking to Steve" do
          expect { state_machine.draw(admin) }.to change { steve.bookings.provisional.count }.by(1)  
        end

        it "drawing the ballot assigns a provisional booking to Ann" do
          expect { state_machine.draw(admin) }.to change { steve.bookings.provisional.count }.by(1)  
        end

        it "drawing the ballot assigns a provisional booking to Roger" do
          expect { state_machine.draw(admin) }.to change { steve.bookings.provisional.count }.by(1)  
        end

        it "drawing the ballot changes the booking in Steve's ballot entry from nil" do
          expect { state_machine.draw(admin) }.to change { steve.ballot_entries.where(ballot: ballot).first.booking }.from(nil)  
        end

        context 'drawing the ballot with the :skip_successful_entrant_notification => true option set' do
          it 'does not deliver any emails' do
            expect { state_machine.draw(admin, skip_successful_entrant_notification: true) }.not_to change { ActionMailer::Base.deliveries.length }
          end
        end

        context 'when the ballot is drawn by an admin' do
          before do
            state_machine.draw(admin)
          end

          it 'the ballot has three successful entries' do
            expect(ballot.successful_entries).to have(3).items
          end

          it 'the ballot has no unsuccessful entries' do
            expect(ballot.unsuccessful_entries).to be_empty
          end
        end

        context 'when Steve already has a confirmed booking' do
          before do
            FactoryBot.create(:booking, aasm_state: :confirmed, user: steve, event: hills)
            expect(steve).to have(1).confirmed_booking
          end

          it 'drawing the ballot creates two new provisional bookings' do
            expect { state_machine.draw(admin) }.to change { Booking.provisional.count }.by(2)
          end
        end

        context 'when Steve already has a provisional booking' do
          before do
            FactoryBot.create(:booking, aasm_state: :provisional, user: steve, event: hills)
            expect(steve).to have(1).provisional_booking
          end

          it 'drawing the ballot creates two new provisional bookings' do
            expect { state_machine.draw(admin) }.to change { Booking.provisional.count }.by(2)
          end
        end

        context 'when Ann has two ballot entries' do
          before do
            FactoryBot.create :ballot_entry, ballot: ballot, user: ann
            expect(ann).to have(2).ballot_entries
          end

          it 'the ballot cannot be drawn' do
            expect(state_machine).not_to allow_event(:draw)
          end
        end
      end
    end
  end
end
 