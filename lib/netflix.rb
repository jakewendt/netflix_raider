require 'oauth'
require 'oauth/consumer'

module Netflix

	URL = {
		:request   => "http://api.netflix.com/oauth/request_token",
		:authorize => "https://api-user.netflix.com/oauth/login",
		:access    => "http://api.netflix.com/oauth/access_token"
	}.freeze

	def self.creds
		@creds ||= begin
			ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/..' 
			rails_file = File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/netflix.yml'))
			if File.exist? rails_file
				YAML.load(File.open(rails_file))
			else
				{
					:application_name => 'My_Netflix_Application_Name',
					:consumer_token   => 'My_Netflix_Consumer_Token',
					:consumer_secret  => 'My_Netflix_Consumer_Secret'
				}
			end
		end
	end

	def self.application_name
		creds[:application_name] || ''
	end

	def self.consumer_token
		creds[:consumer_token] || ''
	end

	def self.consumer_secret
		creds[:consumer_secret] || ''
	end

	def self.query(params={})
		if params.has_key?(:url)	
			path = params.delete(:url)
		else
			path = "/catalog/titles"
		end
		consumer = Netflix::Consumer.new
		if !params[:oauth_token].blank? and !params[:oauth_token_secret].blank?
			#	If I understand this correctly, including the user's token and secret
			#	will allow for more API accesses and MAY include more info in the response.
			access_token = OAuth::AccessToken.new(consumer, params[:oauth_token], params[:oauth_token_secret] )
		else
			access_token = OAuth::AccessToken.new(consumer)
		end
		params_copy = params.dup
		params_copy.delete(:controller)
		params_copy.delete(:action)
		params_copy.delete(:oauth_token)
		params_copy.delete(:oauth_token_secret)

		http_method = params_copy[:http_method]||:get
		params_copy.delete(:http_method)

		if http_method == :get
			# an ampersand in the search term causes failure so parse it out
			params_string = params_copy.keys.map { |key| "#{key}=#{params[key].to_s.gsub(/&/,'')}" }.join('&')
			#	I could check to see if params_string is blank and then remove the trailing ? if needed.
			query_string = "#{path}?#{URI.escape(params_string)}"
			results = access_token.get(query_string)
			#	results = access_token.request(http_method,query_string)
		#	elsif http_method == :put
		#		params_copy[:method] = 'PUT'
		#		params[:method] = 'PUT'
		#		params_string = params_copy.keys.map { |key| "#{key}=#{params[key].to_s.gsub(/&/,'')}" }.join('&')
		#		query_string = "#{path}?#{URI.escape(params_string)}"
		#		results = access_token.request(:get,query_string)
		else
			results = access_token.request(http_method,path,params_copy)
		end

		ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/..' 
		query_file = File.expand_path(File.join(ENV['RAILS_ROOT'], 'query.log'))
		File.open(query_file,'a'){|f|f.puts "#{Time.now} #{results.code} #{query_string||path}" }
		return results
	end

end

class Netflix::Consumer < OAuth::Consumer

	def initialize
		consumer = super(
				Netflix.consumer_token,
				Netflix.consumer_secret,
				{
						:scheme            => :query_string,
						:http_method       => :post,
						:signature_method  => "HMAC-SHA1",
						:site              => "http://api.netflix.com",
						:request_token_url => Netflix::URL[:request],
						:access_token_url  => Netflix::URL[:access],
						:authorize_url     => Netflix::URL[:authorize]
				}
		)
	end

end

class ::Hash

	def delete_keys!(*keys)
		keys.each { |k| self.delete(k) }
		self
	end

end

