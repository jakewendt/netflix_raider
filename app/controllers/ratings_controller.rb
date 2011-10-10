class RatingsController < ApplicationController
	before_filter :require_authorization
	skip_before_filter :verify_authenticity_token, :only => [ :new, :create ]

#	new doesn't actually use the authenticity token does it???

	def create
		@title  = CatalogTitle.find(params[:title_id])
		results = Rating.query_title(@user,@title)
		@rating = if results.is_a?(Array) && results.length > 0
			results[0]
		else
			Rating.new			#	quick fix
		end
		render :action => 'new'
	end

	def new
		@title  = CatalogTitle.find(params[:title_id])
		results = Rating.update_title(@user,@title,params[:rating])
		@rating = if results.is_a?(Array) && results.length > 0
			results[0]
		else
			Rating.new			#	quick fix
		end
	end

end
