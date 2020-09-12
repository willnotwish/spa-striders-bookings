class RedirectApp < ActionController::Metal
  include ActionController::Redirecting

  # def self.call(env)
  #   Rails.logger.debug "RedirectApp.call"
  #   redirect_to '/login'
  # end

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
    # store_location!
    # if is_flashing_format?
    #   if flash[:timedout] && flash[:alert]
    #     flash.keep(:timedout)
    #     flash.keep(:alert)
    #   else
    #     flash[:alert] = i18n_message
    #   end
    # end
    redirect_to redirect_url
  end

  private

  def redirect_url
    '/login'
  end
end
