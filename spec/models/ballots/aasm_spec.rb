require 'rails_helper'

module Ballots
  RSpec.describe 'aasm behaviour', type: :model do
    # Helpers
    def draw_ballot!(user, options = {})
      ballot.draw!(options.merge(user: user))
    end

    def draw_ballot(user, options = {})
      ballot.draw(options.merge(user: user))
    end

    subject { FactoryBot.create :ballot, event: hills }

    let(:hills) { FactoryBot.create :event }
    let(:admin) { FactoryBot.create :user, admin: true }
    let(:regular_user) { FactoryBot.create :user }
    let(:ballot) { subject }

    it { is_expected.to be_closed }
    it { is_expected.not_to be_opened }
    # it { is_expected.not_to allow_event(:draw, user: admin) }

    it 'may not fire :draw with an admin as parameter' do
      expect(ballot.may_draw?(user: admin)).to be_falsy
    end

    it 'when an admin opens the ballot its persisted state changes to opened' do
      expect { ballot.open(user: admin) }.to change { ballot.aasm_state }.to('opened')
    end

    describe 'opening permissions' do
      let(:steve_runner) { FactoryBot.create :user }

      it 'an admin may open the ballot' do
        expect(ballot.may_open?(user: admin)).to eq(true)
      end

      it 'Steve Runner may not open the ballot' do
        expect(ballot.may_open?(user: steve_runner)).to eq(false)
      end

      it 'an anonymous user may not open the ballot' do
        expect(ballot.may_open?(user: nil)).to eq(false)
      end

      it "making steve runner an event admin for hills means that he is able to open the ballot" do
        expect do 
          FactoryBot.create(:event_admin, user: steve_runner, event: hills)
        end.to change { ballot.may_open?(user: steve_runner) }.from(false).to(true)
      end
    end

    context 'when opened by an admin' do
      before do
        ballot.open(user: admin)
      end

      it { is_expected.to be_opened }
      it { is_expected.not_to allow_event(:draw) }
    end

    it 'locking the event allows the ballot to be drawn by an admin' do
      expect { hills.lock(admin) }.to change { ballot.may_draw?(user: admin) }.from(false).to(true)
    end

    it 'locking the event does not allow the ballot to be drawn by a regular user' do
      expect { hills.lock(admin) }.not_to change { ballot.may_draw?(user: regular_user) }
    end

    context 'after the event is locked by an admin' do
      before do
        hills.lock(admin)
        expect(ballot).to be_closed
      end

      it 'can be drawn by an admin' do
        expect(ballot.may_draw?(user: admin)).to eq(true)
      end

      it 'cannot be drawn by a regular user' do
        expect(ballot.may_draw?(user: regular_user)).to eq(false)
      end

      it 'expects an AASM::InvalidTransition exception to be raised when a regular user attempts to draw' do
        expect { ballot.draw(user: regular_user) }.to raise_error(AASM::InvalidTransition)
      end

      it 'drawing the ballot without a bang changes its current state to drawn' do
        expect { ballot.draw(user: admin) }.to change { ballot.aasm.current_state }.from(:closed).to(:drawn)
      end

      it 'drawing the ballot without a bang does not change the persisted ballot\'s state' do
        expect { ballot.draw(user: admin) }.not_to change { Ballot.find(ballot.id).aasm_state }
      end

      it 'drawing the ballot with a bang changes the persisted ballot\'s state' do
        expect { ballot.draw!(user: admin) }.to change { Ballot.find(ballot.id).aasm_state }.to('drawn')
      end

      it '#draw returns true' do
        expect(draw_ballot(admin)).to eq(true)
      end

      it 'drawing an empty ballot does change the number of bookings' do
        expect { draw_ballot!(admin) }.not_to change { Booking.count }
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
        
        it 'drawing the ballot without a bang creates no new provisional bookings' do
          expect { draw_ballot(admin) }.not_to change { Booking.provisional.count }
        end

        it 'drawing the ballot with a bang creates three provisional bookings' do
          expect { draw_ballot!(admin) }.to change { Booking.provisional.count }.by(3)
        end

        it 'drawing the ballot without a bang and then explicitly saving the ballot creates three provisional bookings' do
          expect { draw_ballot(admin); ballot.save }.to change { Booking.provisional.count }.by(3)
        end

        it 'drawing the ballot without a bang sends no emails' do
          expect { draw_ballot(admin) }.not_to change { ActionMailer::Base.deliveries.length }
        end

        it 'drawing the ballot with a bang sends no emails' do
          expect { draw_ballot!(admin) }.not_to change { ActionMailer::Base.deliveries.length }
        end

        it 'drawing the ballot creates no new confirmed bookings' do
          expect { draw_ballot(admin) }.not_to change { Booking.confirmed.count }
        end

        it "drawing the ballot assigns a provisional booking to Steve" do
          expect { draw_ballot!(admin) }.to change { steve.bookings.provisional.count }.by(1)  
        end

        it "drawing the ballot assigns a provisional booking to Ann" do
          expect { draw_ballot!(admin) }.to change { ann.bookings.provisional.count }.by(1)  
        end

        it "drawing the ballot assigns a provisional booking to Roger" do
          expect { draw_ballot!(admin) }.to change { roger.bookings.provisional.count }.by(1)  
        end

        it "drawing the ballot changes the booking in Steve's ballot entry from nil" do
          expect { draw_ballot!(admin) }.to change { steve.ballot_entries.where(ballot: ballot).first.booking }.from(nil)  
        end

        it 'drawing the ballot with a bang does not deliver any emails' do
          expect { draw_ballot!(admin) }.not_to change { ActionMailer::Base.deliveries.length }
        end

        context 'with a bookings collector as an array option' do
          let(:collector) { [] }

          before do
            draw_ballot(admin, { bookings_collector: collector })
          end

          it 'drawing the ballot populates the array with three bookings' do
            expect(collector).to have(3).items
          end
        end

        context 'when the ballot is drawn by an admin' do
          before do
            draw_ballot!(admin)
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
            expect { draw_ballot!(admin) }.to change { Booking.provisional.count }.by(2)
          end
        end

        context 'when Steve already has a provisional booking' do
          before do
            FactoryBot.create(:booking, aasm_state: :provisional, user: steve, event: hills)
            expect(steve).to have(1).provisional_booking
          end

          it 'drawing the ballot with a bang creates two new provisional bookings' do
            expect { draw_ballot!(admin) }.to change { Booking.provisional.count }.by(2)
          end
        end

        context 'when Ann (somehow) has two ballot entries' do
          before do
            entry = FactoryBot.build :ballot_entry, ballot: ballot, user: ann
            entry.save(validate: false)
            expect(ann).to have(2).ballot_entries
          end

          it 'the ballot cannot be drawn' do
            expect(ballot.may_draw?(user: admin)).to be_falsy
          end
        end
      end
    end
  end
end
 