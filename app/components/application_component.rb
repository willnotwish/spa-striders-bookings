class ApplicationComponent < ViewComponent::Base
  attr_reader :except, :root_class, :root_tag

  # def initialize(except: [], only: [], root_class: 'c-component', root_tag: :div)
  #   @except = except.respond_to?(:each) ? except : [except]
  #   @only = only
  #   @root_class = root_class
  #   @root_tag = root_tag  
  # end

  def initialize(options = {})
    except = options.fetch(:except, [])
    @except = except.respond_to?(:each) ? except : [except]
    @only = options.fetch(:only, [])
    @root_class = options.fetch(:root_class, 'c-component')
    @root_tag = options.fetch(:root_tag, 'div')  
  end

  def current_user
    helpers.current_user
  end

  def show?(part)
    except.include?(part) ? false : true
  end

  class BemBuilder
    attr_reader :component, :base

    def initialize(component, base)
      @component = component
      @base = base
    end

    def element(name, options = {}, &block)
      component.build_bem("#{base}__#{name}", self, options, &block)
    end
  end

  def root(options = {}, &block)
    build_bem(root_class, self, options.reverse_merge(tag: root_tag), &block)
  end

  def build_bem(html_class, base_builder, options, &block)
    builder = BemBuilder.new(base_builder, html_class)
    content = capture(builder, &block) if block_given?
    content_tag(options[:tag] || :div, content, class: html_class)
  end

  # def bem_block(options = {}, &block)
  #   content = capture(&block)
  #   classes = [root_class]
  #   modifiers = options[:modify]
  #   if modifiers
  #     modifiers = [modifiers] unless modifiers.respond_to?(:each)
  #     modifiers.each do |modifier|
  #       classes << "#{root_class}--#{send(modifier)}" if respond_to?(modifier)
  #     end
  #   end
  #   content_tag(:div, content, class: classes.join(' '))
  # end

  # def element(name = nil, options = {}, &block)
  #   if block
  #     content = capture(&block)
  #   else
  #     content = send(name)
  #   end
  #   tag_name = options[:tag] || :div
  #   content_tag(tag_name, content, class: "#{root_class}__#{name} #{options[:class]}")
  # end
end
