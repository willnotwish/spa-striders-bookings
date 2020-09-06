class ContactNumbersController < ApplicationController
  before_action :find_contact_number, except: %i[new create]

  def new
    @contact_number = current_user.build_contact_number contact_number_params
    respond_with @contact_number
  end

  def create
    @contact_number = current_user.create_contact_number contact_number_params
    respond_with @contact_number, location: :root
  end

  def edit
  end

  def update
    @contact_number.update contact_number_params
    respond_with @contact_number, location: :root
  end

  def show
    respond_with :contact_number
  end

  private
  
  def contact_number_params
    params.fetch(:contact_number, {}).permit(:phone)  
  end

  def find_contact_number
    @contact_number = current_user.contact_number
  end
end
