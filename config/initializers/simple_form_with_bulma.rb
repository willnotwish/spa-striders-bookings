SimpleForm.setup do |config|
  # Examples of Bulma markup
  
  # For a regular input field:
  #  
  # <div class="field">
  #   <label class="label">Name</label>
  #   <div class="control">
  #     <input class="input" type="text" placeholder="Text input">
  #   </div>
  # </div>  
  #

  # For a select:
  # 
  # <div class="field">
  #   <label class="label">Subject</label>
  #   <div class="control">
  #     <div class="select">
  #       <select>
  #         <option>Select dropdown</option>
  #         <option>With options</option>
  #       </select>
  #     </div>
  #   </div>
  # </div>

  # Without this you get "additional" HTML classes on the wrappers. This messes with Bulma css.
  config.generate_additional_classes_for = [:input]

  config.wrappers :bulma, tag: 'div', class: 'field', error_class: 'has-error' do |b|
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'label'
    b.wrapper tag: 'div', class: 'control' do |bc|
      bc.use :input, class: 'input'
    end
    b.optional :hint, wrap_with: { tag: 'p', class: 'help' }
  end
end
