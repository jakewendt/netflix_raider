module RatingsHelper

	def user_star_bar(rating,title_id)
		"<div  class='star_bar' style='width:140px;'>" <<
		"<span class='hide_me value'>#{rating}</span>" <<
		"<span class='hide_me title_id'>#{title_id}</span>" <<
		"<img  class='acquire' src='/images/favorite_add.png' />" <<
		"<img  class='not_interested' src='/images/nim_#{(rating.to_s=='0')?'high':'low'}.gif' />" <<
		"<img  class='stars'          src='/images/stars_#{rating||0}.gif' />" <<
		"</div>"
	end

	def star_bar(rating)
#			"Rating: #{rating}" <<
		if rating
			"<div class='star_bar'>" <<
			"<span class='stbrMaskBg'>" <<
			"<span class='stbrMaskFg' style='width:#{(rating.to_f*95)/5}px;'>" <<
			"Rating: #{rating}" <<
			"</span>" <<
			"</span>" <<
			"</div>"
		else
			""
		end
	end

end
