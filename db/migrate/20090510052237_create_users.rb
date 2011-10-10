class CreateUsers < ActiveRecord::Migration
	def self.up
		create_table :users do |t|
			t.string :netflix_id
			t.string :oauth_token
			t.string :oauth_token_secret
			t.string :first_name
			t.string :last_name
			t.timestamps
		end
		add_index :users, :netflix_id, :unique => true
	end

	def self.down
		drop_table :users
	end
end
