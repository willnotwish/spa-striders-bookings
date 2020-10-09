require 'rails_helper'

RSpec.describe WaitingList, type: :model do
  it { is_expected.to belong_to(:event) }
  it { is_expected.to have_many(:entries) }
  it { is_expected.to have_many(:users).through(:entries) }
end
