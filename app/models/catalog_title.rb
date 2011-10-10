class CatalogTitle < ActiveRecord::Base
	has_many :ratings

	cattr_reader :per_page
	@@per_page = 50

	attr_accessor :status

	validates_uniqueness_of :netflix_url

	before_save :create_sortable_title

	named_scope :valid_url, :conditions => [ "validated_url IS NOT false" ]
	named_scope :title_like, 
		lambda { |*args| 
			if args.first.blank?
				{}
			else
				{ :conditions => ["title LIKE ?", "%#{args.first.split.join('%')}%"] } 
			end
		}

	#	user_rating desc, sortable_title asc
	#	additionals will exist due to the joins and as's
	def self.untaint_sort(sort="",additionals=['user_rating','predicted_rating'])
		#	add the default and/or last sort 'sortable_title asc'
		# if 'sortable_title desc' is passed, it does as expected
		untainted = (sort||'').split(',').push('sortable_title asc', 'release_year desc').collect do |s|
			ss = s.squish.split()
			col = self.untaint_column(ss[0],additionals)
			if !col.blank?
				if ss.length > 1
					dir = self.untaint_direction(ss[1])
					[col,dir].compact.join(" ").squish
				else
					col
				end
			end
		end.compact.join(", ").squish
	end

	def self.untaint_column(column,additionals=[])
		( self.columns.collect(&:name).push(additionals).flatten.collect(&:downcase).include?(column.downcase.squish) ) ? column.downcase.squish : ""
	end

	def self.untaint_direction(direction)
		( ['asc','desc'].collect(&:upcase).include?(direction.upcase.squish) ) ? direction.upcase.squish : ""
	end

	def self.untaint_page(p=nil)
		( p.to_i > 0 ) ? p.to_i : 1
	end

	def self.untaint_per_page(per=nil)
		( per.to_i > 0 ) ? per.to_i : @@per_page
	end

	def create_sortable_title
		if self.title_changed?
			self.sortable_title = self.title.sub(/^(the|a|an) /i,'')
		end
	end

	def netflix_url_id
		"/#{self.netflix_url.split('/').last}"
	end

	def netflix_url_short
		self.netflix_url.gsub('http://api.netflix.com','')
	end

	def validate_url
		results = Netflix.query(:url => netflix_url)
		if results.code == '200'
			update_attribute(:validated_url,true)
		elsif results.code == '404'	#	#<Net::HTTPNotFound 404 Not Found readbody=true>
			update_attribute(:validated_url,false)
		end
		self
	end

	def self.validate_urls_like(netflix_url)
		find(:all,:conditions => [
			"validated_url IS NULL AND netflix_url LIKE ?", "%/#{netflix_url.split('/').last}"
		]).collect do |ct|
			ct.validate_url
		end
	end

	def self.find_or_query(netflix_url)
		catalog_titles = self.find(:all,:conditions => { :netflix_url => netflix_url })
		if catalog_titles.blank?
			puts "No title found with #{netflix_url}.  Querying."
			results = Netflix.query(:url => netflix_url)
			if results.code == '200'
				new_title = self.find_or_create_one(netflix_url,XmlSimple.xml_in(results.body)) 
				new_title.update_attribute(:validated_url,true)
				validate_urls_like(new_title.netflix_url)
				new_title
			else
				''
			end
		elsif catalog_titles.length == 1
			title = catalog_titles[0]
			title.update_attribute(:validated_url,true)
#			validate_urls_like(title.netflix_url)
			title
		else 
#			validate_urls_like(title.netflix_url)					#	new
#			find_or_query(netflix_url)										#	new
			raise "Multiple catalog_titles found matching #{netflix_url}"
		end
	end

	def self.find_or_create(xml,options={})
		(XmlSimple.xml_in(xml)['catalog_title']||[]).collect do |t|
			self.find_or_create_one(t['id'][0],t,options)
		end
	end

	def self.find_or_create_from_queue(xml)
		(XmlSimple.xml_in(xml)['queue_item']||[]).collect do |t|
			self.find_or_create_one(t['link'].find{|l| l['rel'] == "http://schemas.netflix.com/catalog/title"}['href'],t)
		end
	end

	def self.find_or_create_one(netflix_url,t,options={})
#		found = self.find(:all, :conditions => { :netflix_url => netflix_url })
		found = if options[:user_id].blank?
			self.find(:all, :conditions => { :netflix_url => netflix_url })
		else
			self.find(:all, :conditions => { :netflix_url => netflix_url },
				:select => "catalog_titles.*, ratings.user_rating as user_rating, "<<
					"ratings.predicted_rating as predicted_rating",
				:joins => "LEFT JOIN `ratings` ON ratings.catalog_title_id = catalog_titles.id "<<
					"AND ratings.user_id = #{options[:user_id]}"
			)
		end
		if found.blank?
			new_title = self.create!({
				:netflix_url    => netflix_url,	#	t['id'][0],
				:average_rating => (t['average_rating'])?t['average_rating'][0]:nil,
				:release_year   => (t['release_year'])?t['release_year'][0]:nil,
				:runtime        => (t['runtime'])?t['runtime'][0]:nil,
				:web_page       => t['link'].find{|l|l['title'] == 'web page'}['href'],
				:title          => t['title'][0]['regular'].squish
			})
			new_title.status = 'New!'
			new_title
		elsif found.length == 1
			title = found[0]
			title.attributes = {
#				:title          => t['title'][0]['regular'].squish,
#				:web_page       => t['link'].find{|l|l['title'] == 'web page'}['href'],
				:average_rating => (t['average_rating'])?t['average_rating'][0]:nil,
				:release_year   => (t['release_year'])?t['release_year'][0]:nil,
				:runtime        => (t['runtime'])?t['runtime'][0]:nil
			}
#			title.average_rating = t['average_rating'][0]
			if title.changed?
				title.status = 'Updated!' 
				title.save
			end
			title
		else
			#	should NEVER happen as netflix_url is unique in the database
			raise "Multiple titles found with :netflix_url => #{netflix_url}"
		end
	end

#
#	this is kinda stupid since you could just do user.ratings.collect(&:catalog_title_id)
#
	def self.with_rating(user,params={})
		limit = 2
		next_id = params[:next_id] || user.next_ct_id  || 0
		titles = find(:all,
			:limit      => limit,
			:joins      => "LEFT JOIN `ratings` ON ratings.catalog_title_id = catalog_titles.id AND user_id = #{user.id}",
			:conditions => ["catalog_titles.id >= :next_id " <<
				"AND validated_url IS NOT FALSE " <<
				"AND ratings.user_rating IS NOT NULL",
				{ :next_id => next_id }
			]
		)
	end

	def self.without_rating(user,params={})
		limit = params[:limit] || 2
		next_id = params[:next_id] || user.next_ct_id  || 0
		find(:all,
			:limit      => limit,
			:joins      => "LEFT JOIN `ratings` ON ratings.catalog_title_id = catalog_titles.id AND user_id = #{user.id}",
			:conditions => ["catalog_titles.id >= :next_id " <<
				"AND validated_url IS NOT FALSE " <<
				"AND ratings.user_rating IS NULL",
				{ :next_id => next_id }
			]
		)
	end

	def self.paginated_search(params={})
		search_params = {
			:order    => untaint_sort(params[:sort]),
			:page     => untaint_page(params[:page]), 
			:per_page => untaint_per_page(params[:per_page])
		}
		if params[:user_id]
			search_params[:conditions] = "user_rating IS NOT NULL" if !params[:rated].blank?
			search_params[:select] = "catalog_titles.*, "<<
				"ratings.user_rating as user_rating, ratings.predicted_rating as predicted_rating"
			search_params[:joins] = "LEFT JOIN `ratings` ON ratings.catalog_title_id = catalog_titles.id " <<
				"AND ratings.user_id = #{params[:user_id]}"
		end
		title_like(params[:term]).valid_url.paginate(search_params)
	end

	def self.search(params={})
		search_params = { :order => untaint_sort(params[:sort]) }
		if params[:user_id]
			search_params[:conditions] = "user_rating IS NOT NULL" if !params[:rated].blank?
			search_params[:select] = "catalog_titles.*, "<<
				"ratings.user_rating as user_rating, ratings.predicted_rating as predicted_rating"
			search_params[:joins] = "LEFT JOIN `ratings` ON ratings.catalog_title_id = catalog_titles.id " <<
				"AND ratings.user_id = #{params[:user_id]}"
		end
		valid_url.all(search_params)
	end

	def user_rating
		@user_rating||=(self.has_attribute?(:user_rating))?self.read_attribute(:user_rating):nil
	end
	def predicted_rating
		@predicted_rating||=(self.has_attribute?(:predicted_rating))?self.read_attribute(:predicted_rating):nil
	end

end
