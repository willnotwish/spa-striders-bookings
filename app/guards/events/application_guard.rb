module Events
  class ApplicationGuard < ::ApplicationGuard
    alias_method :event, :model
    # def event
    #   model
    # end
  end
end
