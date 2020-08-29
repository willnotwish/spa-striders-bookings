module Bulma
  class TitleComponent < ApplicationComponent
    attr_reader :text, :kind, :size

    def initialize(text:, size: 2, kind: 'title')
      @text = text
      @size = size
      @kind = kind
    end

    def html_class
      classes = []
      if kind.to_s == 'subtitle'
        classes << 'subtitle'
      else
        classes << 'title'
      end
      classes << "is-#{size}"
      classes.join(' ')
    end

    def tag
      "h#{size}"
    end
  end
end
