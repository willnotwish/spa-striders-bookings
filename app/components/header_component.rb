class HeaderComponent < ApplicationComponent
  def initialize(root_class: 'c-header', root_tag: 'header', root_modifier: nil, except: [])
    super(except: except, root_class: root_class, root_tag: root_tag, root_modifier: root_modifier)
  end

  def main_title
    I18n.t('header.main_title')
  end
end
