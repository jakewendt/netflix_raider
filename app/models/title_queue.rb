class TitleQueue

	attr_reader :start_index, :number_of_results, :results_per_page, :user, :name, :full

	def initialize(user,params={})
		@user        = user
		@name        = (params[:action].blank?||params[:action]=='disc')?'disc':'instant'
		@start_index = (params[:page].blank?)?0:(100*(params[:page].to_i-1))
		@results_per_page = 100
		@full        = (params[:full].blank?)?false:true
	end

	def fetch
		titles = []
		begin
			results = Netflix.query({
				:url => "/users/#{self.user.netflix_id}/queues/#{self.name}",
				:max_results => self.results_per_page,
				:start_index => self.start_index,
				:oauth_token => self.user.oauth_token,
				:oauth_token_secret => self.user.oauth_token_secret
			})
			if ( results.code == '200' )
				set_meta_data_from_query(results.body)
				titles += CatalogTitle.find_or_create_from_queue(results.body)
			else
				return []
			end
			pages_count  = (self.number_of_results / self.results_per_page.to_f).ceil
			current_page = ( self.results_per_page + self.start_index ) / self.results_per_page
			@start_index += self.results_per_page if self.full
		end while ( self.full and current_page < pages_count )
		return titles
	end

	def set_meta_data_from_query(xml)
		h = XmlSimple.xml_in(xml)
		@start_index       = h['start_index'][0].to_i
		#	last results_per_page won't be 100 so have to force it
		@number_of_results = h['number_of_results'][0].to_i
	end

end
