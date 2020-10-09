require 'rails_helper'

RSpec.describe Booking, type: :model do
  it { is_expected.to belong_to(:event) }
  it { is_expected.to belong_to(:user) }

  it { is_expected.to belong_to(:locked_by).optional }
  it { is_expected.to belong_to(:honoured_by).optional }
  it { is_expected.to belong_to(:made_by).optional }

  it { is_expected.to have_many(:transitions) }
end
