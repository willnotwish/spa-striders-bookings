class ContactNumberComponent < ApplicationComponent
  attr_reader :contact_number, :phone

  def initialize(contact_number:)
    @contact_number = contact_number
    @phone = contact_number&.phone || 'No contact number'
  end

  def number_given?
    contact_number&.phone.present?
  end
end
