module Bulma
  class TagComponent < ApplicationComponent
    attr_reader :text, :modifier

    def initialize(text:, modifier:)
      @text = text&.humanize
      @modifier = modifier
    end

    def html_class
      classes = ['tag']
      classes << "is-#{modifier}" if modifier.present?
      classes << 'is-light'
      classes.join(' ')
    end
  end
end
