class User < ApplicationRecord
    validates :email, :members_user_id, presence: true
    validates :members_user_id, uniqueness: true
end
