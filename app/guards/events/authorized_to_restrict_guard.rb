module Events
  class AuthorizedToRestrictGuard < ApplicationGuard
    include PunditAuthorization

    def pass?
      authorized_to? :restrict
    end
  end
end
