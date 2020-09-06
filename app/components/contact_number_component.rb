class ContactNumberComponent < ApplicationComponent
  attr_reader :contact_number

  delegate :phone, to: :contact_number
  delegate :present?, to: :phone

  def initialize(contact_number:, except: [])
    super(root_class: 'c-contact-number', except: except)
    @contact_number = contact_number
  end

  def info
    I18n.t('contact_number.test_and_trace_info')
  end

  def label
    I18n.t('contact_number.test_and_trace_label')
    # "Contact number for NHS Test & Trace"
  end
end
