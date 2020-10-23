class AuthorizedToPopulateEvent < ApplicationGuard
  include PunditAuthorization

  def pass?
    authorized_to? :populate
  end
end
