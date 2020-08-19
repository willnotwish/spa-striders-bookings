require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.not_to be_nil }
  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_presence_of(:members_user_id) }
  it { is_expected.to validate_uniqueness_of(:members_user_id) }
end
