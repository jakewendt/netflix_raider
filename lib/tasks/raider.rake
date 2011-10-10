namespace :raider do

	task :validate_multiples => :environment do
		time_started = Time.now
		CatalogTitle.find(:all, :select => "*, count(*) as count_all", :group => "web_page having count_all > 1").each do |ct|
			puts ct.web_page
			ctws = CatalogTitle.find(:all,:conditions => { :web_page => ct.web_page })
			if ctws.collect(&:validated_url).all? ||
				ctws.collect(&:validated_url).all?{|i|i == false} ||
			 	ctws.collect(&:validated_url).all?{|i|i.nil?}
				ctws.each do |ctw|
					puts "Before:#{ctw.validated_url}"
					ctw.validate_url
					puts "After:#{ctw.validated_url}"
				end
			end
		end
		puts Time.at(Time.now-time_started).gmtime.strftime('%H hours %M minutes %S seconds')
	end

	task :create_sortable_titles => :environment do
		time_started = Time.now
#		offset = 0
#	update catalog_titles set sortable_title = title;
		CatalogTitle.update_all("sortable_title = title")
		%w( the a an ).each do |prefix|
			cts = CatalogTitle.all(:conditions => ["title LIKE ?", "#{prefix} %"])
#		while cts = CatalogTitle.all( :offset => offset, :limit => 10 )
			break if cts.blank?
			cts.each do |ct|
				ct.create_sortable_title
				puts ct.title
				ct.save
#				offset += 1
			end
		end
		puts Time.at(Time.now-time_started).gmtime.strftime('%H hours %M minutes %S seconds')
	end
	

	task :merge_titles => :environment do
		time_started = Time.now
		offset = 69090
		while cts = CatalogTitle.all(:include => :titles, :offset => offset, :limit => 10 )
			break if cts.blank?
			cts.each do |ct|
				puts "#{ct.id},#{ct.titles.detect{|t|t.name == 'regular'}.value},#{ct.titles.detect{|t|t.name == 'short'}.value}"
				ct.update_attributes!(:title => ct.titles.detect{|t|t.name == 'regular'}.value)
				offset += 1
			end
		end
		puts Time.at(Time.now-time_started).gmtime.strftime('%H hours %M minutes %S seconds')
	end

	task :merge_titles_two => :environment do
		time_started = Time.now
		offset = 48100
		while ct = CatalogTitle.first(:include => :titles, :offset => offset )
			puts "#{ct.id},#{ct.titles.detect{|t|t.name == 'regular'}.value},#{ct.titles.detect{|t|t.name == 'short'}.value}"
			ct.update_attributes!(:title => ct.titles.detect{|t|t.name == 'regular'}.value)
			offset += 1
		end
		puts Time.at(Time.now-time_started).gmtime.strftime('%H hours %M minutes %S seconds')
	end

	task :merge_titles_orig => :environment do
		time_started = Time.now
		CatalogTitle.all(:select => 'id', :offset => 25000).collect(&:id).each do |id|
			ct=CatalogTitle.find(id,:include => :titles)
			puts "#{id},#{ct.titles.detect{|t|t.name == 'regular'}.value},#{ct.titles.detect{|t|t.name == 'short'}.value}"
			ct.update_attributes!(:title => ct.titles.detect{|t|t.name == 'regular'}.value)
		end
		puts Time.at(Time.now-time_started).gmtime.strftime('%H hours %M minutes %S seconds')
	end

end
