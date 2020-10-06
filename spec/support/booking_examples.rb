require 'rails_helper'

RSpec.shared_examples 'a valid booking operation' do
  it { is_expected.to be_valid }

  it "#save returns truthy" do
    expect(booking.save).to eq(true)
  end

  it '#save produces a booking the database' do
    expect { booking.save }.to change { Booking.count }.by(1)
  end
end

RSpec.shared_examples "an invalid booking operation" do
  it { is_expected.to be_invalid }

  it "#save returns false" do
    expect(booking.save).to eq(false)
  end

  it '#save produces no change in the number of bookings' do
    expect { booking.save }.not_to change { Booking.count }
  end
end
