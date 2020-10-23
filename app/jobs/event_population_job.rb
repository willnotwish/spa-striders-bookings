class EventPopulationJob < ApplicationJob
  queue_as :default

  def perform(event, check_pending_cancellations: false)
    
  end
end
