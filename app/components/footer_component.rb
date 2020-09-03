class FooterComponent < ApplicationComponent
  delegate :contact_number, to: :current_user

  def initialize(except: [], root_class: 'c-footer', root_modifier: nil)
    super(root_class: root_class, root_tag: 'footer', root_modifier: root_modifier, except: except)
  end

  def copyright
    I18n.t(:copyright)
  end
end
