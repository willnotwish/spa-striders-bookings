class RedirectApp < ActionController::Metal
  include ActionController::Redirecting
  include Devise::Controllers::StoreLocation

  delegate :flash, to: :request

  def self.call(env)
    Rails.logger.debug "RedirectApp.call"
    @respond ||= action(:respond)
    @respond.call(env)
  end

  # # Try retrieving the URL options from the parent controller (usually
  # # ApplicationController). Instance methods are not supported at the moment,
  # # so only the class-level attribute is used.
  # def self.default_url_options(*args)
  #   if defined?(Devise.parent_controller.constantize)
  #     Devise.parent_controller.constantize.try(:default_url_options) || {}
  #   else
  #     {}
  #   end
  # end

  def respond
    # if http_auth?
    #   http_auth
    # elsif warden_options[:recall]
    #   recall
    # else
    #   redirect
    # end
    redirect
  end

  # def http_auth
  #   self.status = 401
  #   self.headers["WWW-Authenticate"] = %(Basic realm=#{Devise.http_authentication_realm.inspect}) if http_auth_header?
  #   self.content_type = request.format.to_s
  #   self.response_body = http_auth_body
  # end

  # def recall
  #   header_info = if relative_url_root?
  #     base_path = Pathname.new(relative_url_root)
  #     full_path = Pathname.new(attempted_path)

  #     { "SCRIPT_NAME" => relative_url_root,
  #       "PATH_INFO" => '/' + full_path.relative_path_from(base_path).to_s }
  #   else
  #     { "PATH_INFO" => attempted_path }
  #   end

  #   header_info.each do | var, value|
  #     if request.respond_to?(:set_header)
  #       request.set_header(var, value)
  #     else
  #       request.env[var]  = value
  #     end
  #   end

  #   flash.now[:alert] = i18n_message(:invalid) if is_flashing_format?
  #   # self.response = recall_app(warden_options[:recall]).call(env)
  #   self.response = recall_app(warden_options[:recall]).call(request.env)
  # end

  def redirect
    store_location!
    # if is_flashing_format?
    #   if flash[:timedout] && flash[:alert]
    #     flash.keep(:timedout)
    #     flash.keep(:alert)
    #   else
    #     flash[:alert] = i18n_message
    #   end
    # end
    flash[:alert] = 'You need to log in'
    redirect_to redirect_url
  end

  private

  def redirect_url
    Rails.application.secrets.members_login_path
  end

  def warden
    request.respond_to?(:get_header) ? request.get_header("warden") : request.env["warden"]
  end

  def warden_options
    request.respond_to?(:get_header) ? request.get_header("warden.options") : request.env["warden.options"]
  end

  def warden_message
    @message ||= warden.message || warden_options[:message]
  end

  def scope
    @scope ||= warden_options[:scope] || :user
  end

  # def scope_class
  #   @scope_class ||= Devise.mappings[scope].to
  # end

  def attempted_path
    warden_options[:attempted_path]
  end

  # Stores requested URI to redirect the user after signing in. We can't use
  # the scoped session provided by warden here, since the user is not
  # authenticated yet, but we still need to store the URI based on scope, so
  # different scopes would never use the same URI to redirect.
  def store_location!
    store_location_for(scope, attempted_path) if request.get?
  end
end
