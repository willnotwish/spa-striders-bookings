class ApplicationComponent < ViewComponent::Base
  attr_reader :except, :modifiers, :root_class, :root_tag, :root_modifier

  def initialize(except: [], 
                 only: [],
                 modifiers: {},
                 root_class: 'c-component',
                 root_tag: :div,
                 root_modifier: nil)
    @except = except.respond_to?(:each) ? except : [except]
    @only = only.respond_to?(:each) ? only : [only]
    @modifiers = modifiers
    @root_class = root_class
    @root_tag = root_tag
    @root_modifier = root_modifier 
  end

  def current_user
    helpers.current_user
  end

  def user_logged_in?
    current_user.present?
  end

  def show?(element)
    except.include?(element) ? false : true
  end

  class << self
    def as_list(collection, options = {})
      with_collection(collection, options.reverse_merge(root_tag: :li))
    end
  end

  class BemBuilder
    attr_reader :component, :base

    def initialize(component, base)
      @component = component
      @base = base
    end

    def element(name, content_or_options_with_block = nil, options = nil, &block)
      return unless component.show?(name)

      # If no content given, either as a block or explicitly, try to get the
      # something from the component implicitly.
      if !block_given? && (content_or_options_with_block.nil? || content_or_options_with_block.is_a?(Hash))
        content = component.send(name) if component.respond_to?(name)
        if content.present?
          options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
          content_or_options_with_block = content
        end
      end
      
      bem_element_class = "#{base}__#{name.to_s.dasherize}"
      modifier = component.modifiers[name]
      component.bem_tag(self, bem_element_class, modifier, content_or_options_with_block, options, &block)
    end
  end

  def root(options = {}, &block)
    classes = [root_class]
    classes << "#{root_class}--#{root_modifier}" if root_modifier.present?   
    bem_tag(self, root_class, root_modifier, options.reverse_merge(tag: root_tag), &block)
  end

  def bem_tag(base_builder, block_or_element_class, modifier = nil, content_or_options_with_block = nil, options = nil, &block)

    # Here is the Rails version of content_tag for reference:
    # 
    # def content_tag(name, content_or_options_with_block = nil, options = nil, escape = true, &block)
    #   if block_given?
    #     options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
    #     tag_builder.content_tag_string(name, capture(&block), options, escape)
    #   else
    #     tag_builder.content_tag_string(name, content_or_options_with_block, options, escape)
    #   end
    # end
  
    # First, decide on the content
    if block_given?
      options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
      builder = BemBuilder.new(base_builder, block_or_element_class)
      content = capture(builder, &block)
    else
      content = content_or_options_with_block
    end

    # The tag name may be given as an option. Default is <div>
    tag_name = options ? options[:tag] : nil
    tag_name ||= :div

    classes = [block_or_element_class]
    classes << "#{block_or_element_class}--#{modifier}" if modifier.present?

    # TODO. Add HTML classes from options hash

    content_tag(tag_name, content, class: classes.join(' '))
  end
end
