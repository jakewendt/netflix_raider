class AddNextOffsetToUser < ActiveRecord::Migration
	def self.up
		add_column :users, :next_offset, :integer, :default => 0
	end

	def self.down
		remove_column :users, :next_offset
	end
end
