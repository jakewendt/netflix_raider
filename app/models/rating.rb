class Rating < ActiveRecord::Base
	belongs_to :user, :counter_cache => true
	belongs_to :catalog_title

	cattr_reader :per_page
	@@per_page = 50

	def self.find_or_create(params={})
		ratings = self.find(:all,:conditions => params)
		if ratings.blank?
			self.create!(params)
		elsif ratings.length == 1
			ratings[0]
		else
			raise "Multiple ratings found matching #{params.inspect}"
		end
	end

	def self.raid(user,params={})
		limit = 250
		offset  = params[:offset]  || user.next_offset || 0
		next_id = params[:next_id] || user.next_ct_id  || 0
		titles = CatalogTitle.send('without_rating',user,{:limit => limit})
		results = self.query_titles(user,titles,params)
		if results.is_a?(Array)			#	if Array, it's an Array of Ratings
			user.update_attributes({
				:next_offset => offset + titles.length,
				:next_ct_id  => titles.last.id + 1
			})
		end
		return results
	end

	def self.update_title(user,title,rating)
		put_results = Netflix.query({ 
			:url => "/users/#{user.netflix_id}/ratings/title/actual#{title.netflix_url_id}", 
			:oauth_token => user.oauth_token, 
			:oauth_token_secret => user.oauth_token_secret, 
			:method => 'PUT', 
			:rating => rating
		})
		self.query_titles(user,[title])
	end

	def self.query_title(user,title,params={})
		self.query_titles(user,[title],params)
	end

	def self.query_titles(user,titles,params={})
		if titles.blank?
			return "No titles found matching given params"
		else
			title_refs = titles.collect(&:netflix_url_id).join(',')
		end
		results = Netflix.query({
			:url => "/users/#{user.netflix_id}/ratings/title",
			:title_refs => title_refs,
			:oauth_token => user.oauth_token,
			:oauth_token_secret => user.oauth_token_secret
		})
		if results.code == '200'
			self.update_from_xml(user,results.body)	#	returns an array of new ratings (could be empty)
		else
			#	400:Bad Request:#<Net::HTTPBadRequest 400 Bad Request readbody=true>,Missing Required Access Token
			#	401:Unauthorized:#<Net::HTTPUnauthorized 401 Unauthorized readbody=true>
			#	414:Request-URI Too Long:#<Net::HTTPRequestURITooLong 414 Request-URI Too Long readbody=true>
			#	500:Internal Server Error:#<Net::HTTPInternalServerError 500 Internal Server Error readbody=true>
			#	502:Bad Gateway:#<Net::HTTPBadGateway 502 Bad Gateway readbody=true>
			#	504:Gateway Timeout
			puts "#{results.code}:#{results.msg}:#{results.inspect},#{results.body}"
			results		#	return query results when there's a problem
		end
	end
	
	def self.update_from_xml(user,xml)
		(XmlSimple.xml_in(xml)['ratings_item']||[]).collect do |r|
			next if r['link'].blank?
			netflix_url = r['link'].find{|l| l['rel'] == "http://schemas.netflix.com/catalog/title"}['href']
			ct = CatalogTitle.find_or_query(netflix_url)	#	set validated_url in here
			if ct.blank?
				puts "No catalog title found with netflix_url => #{netflix_url}"
				nil
			else
				new_attrs = {}
				if r['average_rating'] and !r['average_rating'][0].nil?
					new_attrs[:average_rating] = r['average_rating'][0] 
				end
				if r['release_year'] and !r['release_year'][0].nil?
					new_attrs[:release_year] = r['release_year'][0] 
				end
				if r['runtime'] and !r['runtime'][0].nil?
					new_attrs[:runtime] = r['runtime'][0] 
				end
				ct.update_attributes({
					:validated_url  => true,
				}.merge(new_attrs))
				if r['user_rating']
					rating = Rating.find_or_create({
						:user_id          => user.id,
						:catalog_title_id => ct.id
					})
					user_rating = case r['user_rating'][0].class.to_s
						when "String" then r['user_rating'][0]
						else 0		#	{value => not_interested}	otherwise this is recorded as "1" (true)
					end
					rating.update_attributes!({
						:user_rating      => user_rating,
						:predicted_rating => r['predicted_rating'][0]
					})
					rating
				else
					ratings = Rating.delete_all({		#	using delete_all just in case there are more than one
						:user_id          => user.id,
						:catalog_title_id => ct.id
					})
					nil
				end
			end
		end.compact #	(XmlSimple.xml_in(results.body)['ratings_item']||[]).collect do |r|
	end	#	def self.update_from_xml(user,xml)
	
end
