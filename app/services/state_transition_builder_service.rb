class StateTransitionBuilderService
  attr_reader :model, :user
  delegate :aasm, to: :model

  def initialize(model, user: nil, **)
    @model = model
    @user = user
  end

  def call
    model.transitions.build(source: user,
                            from_state: aasm.from_state,
                            to_state: aasm.to_state)
  end
end
