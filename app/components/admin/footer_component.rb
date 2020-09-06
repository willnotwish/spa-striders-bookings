module Admin
  class FooterComponent < FooterComponent
    def initialize(except: [])
      super(root_modifier: 'admin', except: except)
    end
  end
end
