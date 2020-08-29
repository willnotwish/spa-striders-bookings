class BookingPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user.present?

      user.admin? ? scope.all : scope.merge(user.bookings)
    end
  end
end
