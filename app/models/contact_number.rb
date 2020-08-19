class ContactNumber < ApplicationRecord
  belongs_to :user

  validates :phone, presence: true
end
