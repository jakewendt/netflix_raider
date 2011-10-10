class AddUserIdCatalogTitleIdUniqueIndexToRatings < ActiveRecord::Migration
	def self.up
		add_index :ratings, [:user_id,:catalog_title_id], :name => 'join_ids', :unique => true
	end

	def self.down
		remove_index :ratings, :name => 'join_ids'
	end
end
