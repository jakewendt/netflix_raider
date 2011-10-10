class QueriesController < ApplicationController
	before_filter :require_params_term,   :only => :show
	before_filter :require_authorization

	def new

	end

	def show
		params_copy = params.dup.delete_keys!(:action,:controller)
		params_copy[:oauth_token]        = session[:oauth_token]
		params_copy[:oauth_token_secret] = session[:oauth_token_secret]
		@results = Netflix.query(params_copy.merge({:url => '/catalog/titles',:max_results => 100}))
		@titles = ( @results.code == '200' ) ? CatalogTitle.find_or_create(@results.body,:user_id => @user.id) : []
	end

protected

	def require_params_term
		redirect_to new_query_path unless !params[:term].blank?
	end

end
