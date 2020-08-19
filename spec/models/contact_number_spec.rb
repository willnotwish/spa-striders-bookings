require 'rails_helper'

RSpec.describe ContactNumber, type: :model do
  it { is_expected.to validate_presence_of(:phone) }
end
