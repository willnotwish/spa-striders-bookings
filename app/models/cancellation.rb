class Cancellation
  include ActiveModel::Model
  include ActiveModel::Validations
  
  attr_accessor :booking

  validates :booking, presence: true
  validate :check_booking

  def save
    return false unless valid?

    booking.cancel
    booking.save
  end

  class << self
    def create(attrs)
      new(attrs).tap do |instance|
        instance.save
      end
    end
  end

  private

  def check_booking
    return if !booking || booking.may_cancel?

    @errors[:booking] << 'may not be cancelled at this time' 
  end
end