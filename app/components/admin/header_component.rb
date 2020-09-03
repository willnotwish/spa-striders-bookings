module Admin
  class HeaderComponent < ::HeaderComponent
    def initialize(except: [])
      super(root_modifier: 'admin', except: except)
    end

    def title
      I18n.t('header.admin.title')
    end
  end
end
