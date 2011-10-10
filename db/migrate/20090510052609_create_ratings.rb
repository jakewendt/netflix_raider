class CreateRatings < ActiveRecord::Migration
	def self.up
		create_table :ratings do |t|
			t.integer :user_id
			t.integer :catalog_title_id
			t.integer :user_rating
			t.decimal :predicted_rating, :precision => 2, :scale => 1
			t.timestamps
		end
	end

	def self.down
		drop_table :ratings
	end
end
