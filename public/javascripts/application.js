var showEms = function(){
  var em_value = $(window).width() / parseInt($('body').css('font-size'));
  $('.screen-width').text(' ' + em_value + 'em');
  return true;
};

// General UX interactions
// need to make better
$(document).ready(function() {
	
	$(".nav_toggle").click(function () {
		$(".toadstool_nav").slideToggle("slow");
	});
	

	$(".click_more a").click(function () {
		event.preventDefault();
		$(this).parents("p").siblings(".read_more").slideToggle("slow");
		//$(this).parents("p").children("a").text("Read less ...");
	});
	
	$(".codeToggle a").click(function () {
		event.preventDefault();
		$(this).parents("p").siblings(".prettyprint").slideToggle("slow");
	});
	
	
	showEms();
	
});





// will show em size of window on resize of view
$(window).resize(function() {
	showEms();
});

// forces mobile address bar to scroll up
if (/mobile/i.test(navigator.userAgent) && !window.location.hash) { window.onload = function () {
  window.scrollTo(0, 1);
}; }





//// function to get hex value to appear on color guide
function rgb2hex(rgb) {
    rgb = rgb.match(/^rgba?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*([\d\.]+))?\)$/);
    function hex(x) {
        return ("0" + parseInt(x).toString(16)).slice(-2);
    }
    if (rgb[1]!=0||rgb[2]!=0||rgb[3]!=0){
      return ("#" + hex(rgb[1]) + hex(rgb[2]) + hex(rgb[3])).toUpperCase();
    }
    // if (rgb[1]!=255||rgb[2]!=255||rgb[3]!=255){
    //   $("div").addClass("myClass yourClass");
    // }
    else {
      return 'Gradient - Please use your web inspector';
    }
}

$(document).ready(function() {
  $('article.colorcode').children('div').each(function(index, BlockColor){
    var color = $(BlockColor).css("background-color"); 
    $(BlockColor).children().append('<br>' + '<b>' + rgb2hex(color) + '</b>');
  });
});