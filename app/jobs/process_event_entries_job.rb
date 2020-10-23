class ProcessEventEntriesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    BuildBookingsFromEventEntriesService.call(*args)
  end
end
