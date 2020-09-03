module Admin
  class PageTitleComponent < ApplicationComponent
    attr_reader :title

    def initialize(title:)
      @title = title
    end
  end
end
