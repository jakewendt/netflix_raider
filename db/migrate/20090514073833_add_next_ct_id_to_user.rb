class AddNextCtIdToUser < ActiveRecord::Migration
	def self.up
		add_column :users, :next_ct_id, :integer, :default => 0
	end

	def self.down
		remove_column :users, :next_ct_id
	end
end
