(function($) {

  // $(".chzn-select").chosen().change(function() {
  //   console.log($(this));
  // });
  // $(".chzn-select-deselect").chosen({allow_single_deselect:true, max_selected_options:3});

  $('select[name=syntax], select[name=output]').each(function() {
    $(this).dropdown({
      gutter : 0,
      speed : 25
    })
  });
  
  $('select[name=plugin]').each(function() {
    $(this).dropdown({
      gutter : 0,
      speed : 25,
      onOptionSelect: function(opt) {
        var plugins = opt.data( 'value' );        
        
        console.log($('input[name=syntax]').val());
        
        $.each(plugins.split(','), function(key, plugin) {
          
          
          sass.insert( '@import "' + plugin + '"' + ( $('[name=syntax]').val() == 'scss' ? ';' : '' ) + '\n\n');
        });
        
      }
    })
  });


})(jQuery);




// Chrome 26 needs this
// Safari 6 needs this

// Firefox 19 doesn't need it
// IE 10 doesn't need it

$(function() {

	causeRepaintsOn = $(".chzn-container, .chzn-drop, .fancy_dropdown div");

	$(window).resize(function() {
		causeRepaintsOn.css("width", '100%');
	});



  // $('.chzn-drop').on('mouseleave', function() {
  //   
  // });


});
