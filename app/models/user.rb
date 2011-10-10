class User < ActiveRecord::Base
	has_many :ratings

	validates_uniqueness_of :netflix_id

	def full_name
		"#{first_name} #{last_name}"
	end

	def is_jake?
		self.netflix_id == "T1_a5md.6Q0BDlDfhX_BieYTqs1wkQJb1m1NexlfmYXqY-"
	end

end
