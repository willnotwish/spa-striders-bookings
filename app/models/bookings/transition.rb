module Bookings
  class Transition < ApplicationRecord
    belongs_to :booking
    belongs_to :source, polymorphic: true, optional: true
  end
end
