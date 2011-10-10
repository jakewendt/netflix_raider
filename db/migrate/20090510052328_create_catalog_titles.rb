class CreateCatalogTitles < ActiveRecord::Migration
	def self.up
		create_table :catalog_titles do |t|
#			t.integer :netflix_id
			t.string  :netflix_url
			t.string  :title
			t.integer :runtime
			t.integer :release_year
#			t.integer :training_set_id
			t.string  :web_page
			t.decimal :average_rating, :precision => 2, :scale => 1
			t.boolean :validated_url
			t.timestamps
#			t.string  :source
		end
		add_index :catalog_titles, :netflix_url, :unique => true
#		add_index :catalog_titles, :training_set_id, :unique => true
	end

	def self.down
		drop_table :catalog_titles
	end
end
