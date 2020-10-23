module Events
  class AuthorizedToPublishGuard < ApplicationGuard
    include PunditAuthorization

    def pass?
      authorized_to? :publish
    end
  end
end
