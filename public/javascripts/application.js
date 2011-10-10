
star_titles = [
	"Hated it!",
	"Didn't like it",
	"Liked it",
	"Really liked it",
	"Loved it!"
];

function rate_title(t,rating) {
	title_id = $(t).siblings('span.title_id').html()
	if( title_id > 0 ) {
		rate_title_id(title_id,rating)
	} else {
		if(confirm("Rate all these titles '"+rating+"'?\nAre you sure?")) {
			$('span.title_id').each( function() {
				title_id = $(this).html()
				if( title_id > 0 ) {
					rate_title_id(title_id,rating)
				}
			});
		}
	}
}

function rate_title_id(title_id,rating) {
//	alert("ID: "+title_id+" Rating:"+rating)
	$.ajax({
		dataType:'script', 
		type:'get', 
		url:'/ratings/new?title_id='+title_id+'&rating='+rating
	});
}

function acquire_rating(t) {
	title_id = $(t).siblings('span.title_id').html()
	if( title_id > 0 ) {
		acquire_rating_id(title_id)
	} else {
		if(confirm("Acquire ratings for all these titles?\nAre you sure?")) {
			$('span.title_id').each( function() {
				title_id = $(this).html()
				if( title_id > 0 ) {
					acquire_rating_id(title_id)
				}
			});
		}
	}
}

function acquire_rating_id(t) {
//	alert("ID: "+title_id)
	$.ajax({
		dataType:'script', 
		type:'post', 
		url:'/ratings?title_id='+title_id
	});
}


function add_rating_listeners(id) {
	id = (typeof(id) == 'undefined')?'':id
	$(id+' .acquire').attr('title','Refresh your rating from Netflix.')
	$(id+' .not_interested').attr('title','I am not interested in this title.')

	$(id+' .not_interested').mouseover(function(){
		$(this).attr('src','/images/nim_high.gif')
	});

	$(id+' .not_interested').mouseout(function(){
		val = $(this).siblings('span.value').html()
		if( val == '0' ){
			$(this).attr('src','/images/nim_high.gif')
		} else {
			$(this).attr('src','/images/nim_low.gif')
		}
	});

	$(id+' .not_interested').click(function(){
		rate_title(this,'not_interested');
		return false;
	});

	$(id+' .acquire').click(function(){
		acquire_rating(this);
		return false;
	});

	$(id+' .stars').click(function(e){
		rating   = parseInt((18 + e.clientX - $(this).offset().left)/18)
		rate_title(this,rating);
		return false;
	});

	$(id+' .stars').mousemove(function(e){
/*
		rating   = parseInt((19 + e.clientX - $(this).offset().left)/19)
alert(e.clientX + " - " + $(this).offset().left + "+19 / 19 " + rating)
		rating   = Math.floor(Math.ceil( e.clientX - $(this).offset().left + 19 ) / 19 );	
		rating   = Math.floor( ( e.clientX - $(this).offset().left + 19 ) / 19 );	
*/
		/* ( e.clientX - $(this).offset().left ) -> 0.5 - 91.5 */
		rating   = Math.ceil( ( e.clientX - $(this).offset().left ) / 19 );	
		$(this).attr('src','/images/stars_'+rating+'.gif');
		$(this).attr('title',star_titles[rating-1])
	});

	$(id+' .stars').mouseout(function(){
		val = $(this).siblings('span.value').html() || '0'
		$(this).attr('src','/images/stars_'+val+'.gif');
	});

}



$(function(){

	add_rating_listeners();

});
