class ApplicationComponent < ViewComponent::Base
  def current_user
    helpers.current_user
  end

  def bem_block(options = {}, &block)
    content = capture(&block)
    classes = [root_class]
    modifiers = options[:modify]
    if modifiers
      modifiers = [modifiers] unless modifiers.respond_to?(:each)
      modifiers.each do |modifier|
        classes << "#{root_class}--#{send(modifier)}" if respond_to?(modifier)
      end
    end
    content_tag(:div, content, class: classes.join(' '))
  end

  def element(name = nil, options = {})
    content = send(name)
    tag_name = options[:tag] || :div
    content_tag(tag_name, content, class: "#{root_class}__#{name}")
  end
end
