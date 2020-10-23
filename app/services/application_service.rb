# A service relates to a single model.
# 
# A service must define a #call method, which takes no parameters. #call may
# modify the model or its associations in memory only.
# 
# Services can call third party APIs, perform calculations, build related
# objects, etc, but must not perform any database updates.
# 
# Once a service has been called, the calling controller is responsible
# for persisting changes, rendering html/js/emails and so on.
# 

class ApplicationService
  attr_accessor :model     # the model to which this service relates

  # Derived classes must remember to call super in their #initialize method,
  # if they have one
  def initialize(model, **)
    @model = model
  end

  def call
    raise 'You must define a #call method for your service'
  end

  class << self
    # Syntactic sugar to allow you to do 
    #   CakeDecorationService.call(sponge, icing_colour: :pink)
    # instead of
    #   CakeDecorationService.new(sponge, icing_colour: :pink).call    
    # Not a big deal.
    def call(*args)
      new(*args).call
    end
  end
end
