module PunditAuthorization
  extend ActiveSupport::Concern

  included do
    attr_reader :user
    alias_method :authorized_to?, :authorized?
  end

  def initialize(ballot, user:, **)
    super 
    @user = user
  end

  def authorized?(event_name)
    policy = Pundit.policy(user, model)
    policy&.send("#{event_name}?")
  end
end
