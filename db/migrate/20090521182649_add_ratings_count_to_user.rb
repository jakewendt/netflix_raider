class AddRatingsCountToUser < ActiveRecord::Migration
	def self.up
		add_column :users, :ratings_count, :integer, :default => 0
	end

	def self.down
		remove_column :users, :ratings_count
	end
end
