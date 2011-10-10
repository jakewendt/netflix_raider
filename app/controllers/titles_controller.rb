class TitlesController < ApplicationController
	before_filter :check_user
	before_filter :get_title, :except => :index
	before_filter :require_jake, :only => [ :edit, :update, :validate ]

	def index
		params[:user_id] = @user.id if @user
		if params[:format].blank?
			@titles = CatalogTitle.paginated_search(params)
		else
			@titles = CatalogTitle.search(params)
		end

		respond_to do |format|
			format.html {}
			format.xml { render :xml => @titles.to_xml }
			format.csv do
				headers["Content-disposition"] = "attachment; filename=MovieRatings_#{Time.now.to_s(:filename)}.csv"
				render :text => "# User Rating, Predicted Rating, Average Rating, Release Year, Title, Netflix Web Page\n" <<
					"#{@titles.collect{|t| "#{t.user_rating}," <<
						"#{t.predicted_rating}," <<
						"#{t.average_rating}," <<
						"#{t.release_year}," <<
						"'#{t.title}'," <<
						"#{t.web_page}" }.join("\n")}\n"
			end
		end
	end

	def update
		if @title.update_attributes(params[:catalog_title])
			flash[:notice] = 'CatalogTitle was successfully updated.'
			redirect_to	title_path(@title)
		else
			render :action => "edit"
		end
	end

	def validate
		@title.validate_url
	end

protected

	def get_title
		@title = CatalogTitle.find(params[:id])
	end

	def require_jake
		unless @user.is_jake?
			flash[:error] = "Sorry, you are not authorized to do that."
			redirect_to root_path
		end
	end

end
