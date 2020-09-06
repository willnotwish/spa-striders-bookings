class SelfServiceBookingsController < ApplicationController
  before_action :ensure_guest_or_member!
  before_action :ensure_terms_accepted!
  before_action :ensure_contact_number!
  before_action :build_self_service_booking

  def new
    respond_with @self_service_booking
  end

  def create
    @self_service_booking.save
    respond_with @self_service_booking, location: :root
  end

  private

  def booking_params
    params.fetch(:self_service_booking, {}).permit(:event_id)
  end

  def build_self_service_booking
    @self_service_booking ||= 
      SelfServiceBooking.new(booking_params.merge(user: current_user))
  end

  def ensure_guest_or_member!
    # Could be "guest period expired"
    forbidden unless current_user.guest? || current_user.member?
  end

  def ensure_terms_accepted!
    unless current_user.has_accepted_terms?
      redirect_to([:new, :terms, :acceptance], alert: I18n.t(:accept_terms))
    end
  end

  def ensure_contact_number!
    redirect_to [:new, :contact_number] unless current_user.phone.present?
  end
end
