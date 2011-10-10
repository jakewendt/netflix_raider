class RaidsController < ApplicationController
	before_filter :require_authorization

	def new

	end

	def create
		@results = Rating.raid(@user)
	end

	def show
		@user.update_attribute(:next_ct_id,0) if params[:reset]
	end

end
