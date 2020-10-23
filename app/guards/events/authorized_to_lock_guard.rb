module Events
  class AuthorizedToLockGuard < ApplicationGuard
    include PunditAuthorization

    def pass?
      authorized_to? :lock
    end
  end
end
