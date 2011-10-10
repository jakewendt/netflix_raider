class AuthorizationsController < ApplicationController
	before_filter :check_user

	def new
		session[:return_to] = request.env["HTTP_REFERER"]
		redirect_to user_path
	end

	def destroy
		if @user
			@user.update_attributes({
				:oauth_token => nil,
				:oauth_token_secret => nil
			})
		end
		reset_session
		redirect_to root_path
	end

end
