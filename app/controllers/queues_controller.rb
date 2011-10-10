class QueuesController < ApplicationController
	before_filter :require_authorization

	def disc
		@q = TitleQueue.new(@user,params)
		@titles = @q.fetch
		respond_to do |format|
			format.html {}
			format.csv  {
				headers["Content-disposition"] = "attachment; filename=NetflixDiscQueue_#{Time.now.to_s(:filename)}.csv"
			}
		end
	end

	def instant
		@q = TitleQueue.new(@user,params)
		@titles = @q.fetch
		respond_to do |format|
			format.html {}
			format.csv  {
				headers["Content-disposition"] = "attachment; filename=NetflixInstantQueue_#{Time.now.to_s(:filename)}.csv"
			}
		end
	end

end
