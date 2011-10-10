class AddSortableTitleToCatalogTitles < ActiveRecord::Migration
	def self.up
		add_column :catalog_titles, :sortable_title, :string
	end

	def self.down
		remove_column :catalog_titles, :sortable_title
	end
end
