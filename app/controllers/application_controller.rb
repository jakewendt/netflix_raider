class ApplicationController < ActionController::Base

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '842e90e9c1ef5333923e33f3835a1aae'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

protected

	def check_user
		if !session[:netflix_user_id].blank?
			@user = User.find_or_create_by_netflix_id(session[:netflix_user_id])
		end
	end

	def require_authorization
		consumer = Netflix::Consumer.new
		if !session[:netflix_user_id].blank? and !session[:oauth_token].blank? and !session[:oauth_token_secret].blank?
			
			#	got everything that I need (although its possible that it could be invalid?)

			#	@access_token = OAuth::AccessToken.new( @consumer, session[:oauth_token], session[:oauth_token_secret])

			@user = User.find_or_create_by_netflix_id(session[:netflix_user_id])
		elsif !session[:token].blank? and !session[:secret].blank?
			request_token = consumer.get_request_token
			request_token.token  = session[:token]	#	I don't like doing this
			request_token.secret = session[:secret]	#	I don't like doing this
			access_token = request_token.get_access_token
			session[:token]  = nil	#	would like to delete the key, but apparently can't
			session[:secret] = nil	#	would like to delete the key, but apparently can't
			session[:oauth_token]        = access_token.params[:oauth_token]
			session[:oauth_token_secret] = access_token.params[:oauth_token_secret]
			session[:netflix_user_id]    = access_token.params[:user_id]
			@user = User.find_or_create_by_netflix_id(session[:netflix_user_id])
		else
			request_token = consumer.get_request_token
			session[:token] = request_token.token
			session[:secret] = request_token.secret
			session[:return_to] ||= request.url
			redirect_to request_token.authorize_url({ 
				"application_name"   => Netflix.application_name, 
				"oauth_consumer_key" => Netflix.consumer_token,
				'oauth_callback'     => user_url		#	request.url
			})
		end
	rescue
		#	if the user initiates an authorization, token and secret exist but are no longer valid
		#	so the request_token.get_access_token will fail.
		#	This may actually be useful elsewhere.
		redirect_to logout_path
	end

end
