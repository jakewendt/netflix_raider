module ApplicationHelper

	def query_pagination_links(params,start_index,number_of_results,results_per_page)
		pages_count  = (number_of_results / results_per_page.to_f).ceil
		current_page = ( results_per_page + start_index ) / results_per_page

#<span class="disabled prev_page">&laquo; Previous</span>
#<span class="current">1</span> 
#<a href="/ratings?page=2" rel="next">2</a> 
#<a href="/ratings?page=3">3</a> 
#<span class="gap">&hellip;</span> 
#<a href="/ratings?page=39">39</a> 
#<a href="/ratings?page=2" class="next_page" rel="next">Next &raquo;</a>
		pagination_links = if pages_count > 1
			"#{previous_page(params,current_page)}" <<
				"#{page_links(params,current_page,pages_count)}" <<
				"#{next_page(params,current_page,pages_count)}"
		else
			""
		end
		"<div class='pagination'>#{pagination_links}</div>"
	end

	def previous_page(params,current_page)
		if current_page > 1
			link_to "&laquo; Previous", params.merge(:page => current_page - 1), :class => "prev_page"
		else
			"<span class='disabled prev_page'>&laquo; Previous</span>"
		end
	end

	def next_page(params,current_page,pages_count)
		if current_page < pages_count
			link_to "Next &raquo;", params.merge(:page => current_page + 1), :class => "next_page"
		else
			"<span class='disabled next_page'>Next &raquo;</span>"
		end
	end

	def page_links(params,current_page,pages_count)
		(1..pages_count).collect do |p|
			if p == current_page
				"<span class='current'>#{p}</span>"
			else
				link_to "#{p}", params.merge(:page => p)
			end
		end
	end

end
