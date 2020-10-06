module Bulma
  class ButtonComponent < ApplicationComponent

    attr_reader :text, :modifier, :size, :url

    def initialize(text:, modifier: nil, active: true, size: nil, url: nil)
      @text = text
      @modifier = modifier
      @size = size
      @active = active
      @url = url
    end

    def active?
      @active
    end

    def disabled?
      !active?
    end

    def html_class
      classes = %w[button]
      classes << modifier.to_s.dasherize if modifier.present?
      classes.join(' ')
    end
  end
end
