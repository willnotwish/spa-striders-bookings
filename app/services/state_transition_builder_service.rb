class StateTransitionBuilderService < ApplicationService
  attr_reader :user
  delegate :aasm, to: :model

  def initialize(model, user: nil, **)
    super
    @user = user
  end

  def call
    model.transitions.build(source: user,
                            aasm_event: aasm.current_event,
                            from_state: aasm.from_state,
                            to_state: aasm.to_state)
  end
end
