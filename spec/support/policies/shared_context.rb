require 'rails_helper'

RSpec.shared_context 'policy context' do
  subject { described_class.new(user, record) }

  let(:steve_runner) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, admin: true) }
  let(:session_leader) do
    FactoryBot.create(:user).tap do |user|
      FactoryBot.create(:event_admin, user: user, event: event)
    end
  end
  let(:resolved_scope) do
    described_class.name =~ /(.*)Policy/
    klass = $1.constantize
    described_class::Scope.new(user, klass.all).resolve
  end

  let(:policy) { subject }
end
