class UsersController < ApplicationController
	before_filter :require_authorization

	def show
		@user.oauth_token        = session[:oauth_token]
		@user.oauth_token_secret = session[:oauth_token_secret]
		if @user.first_name.blank? || @user.last_name.blank?
			params_copy = params.dup.delete_keys!(:action,:controller)
			params_copy[:oauth_token]        = session[:oauth_token]
			params_copy[:oauth_token_secret] = session[:oauth_token_secret]
			@results = Netflix.query(params_copy.merge({ :url => "/users/#{@user.netflix_id}" }))
			h = XmlSimple.xml_in(@results.body)
			@user.first_name = h['first_name'][0]
			@user.last_name  = h['last_name'][0]
		end
		@user.save
		redirect_to session[:return_to]||home_path
		session[:return_to] = nil
	end

end
