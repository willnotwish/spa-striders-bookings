module TimingMethods
  extend ActiveSupport::Concern

  class_methods do
    def declare_timing_methods(*timestamp_readers)
      timestamp_readers.each do |timestamp_reader|
        define_method("#{timestamp_reader}_date") do
          I18n.l(send(timestamp_reader), format: :date)
        end

        define_method("#{timestamp_reader}_time") do
          I18n.l(send(timestamp_reader), format: :hm)
        end
      end
    end
  end
end
