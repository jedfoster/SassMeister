(function($) {
  var SassMeister = window.SassMeister.init();

  $("a[href^='http://'], a[href^='https://']").attr("target", "_blank");

  SassMeister.inputs.sass.getSession().on('change', function(e) {
    SassMeister.setTimer(SassMeister.timers.sass, SassMeister.compile.sass);
  });

  // $('#sass-form select').on('change', function() {
  //   _gaq.push(['_trackEvent', 'Form', 'Control', this.value]);
  // 
  //   SassMeister.convert.sass();
  // });

  $('#info, .logo').on('click', function() {
    event.preventDefault();

    $('#footer').reveal({
      animation: 'fadeAndPop', //fade, fadeAndPop, none
      animationSpeed: 250, //how fast animations are
      closeOnBackgroundClick: true, //if you click background will modal close?
      dismissModalClass: 'close-icon' //the class of a button or element that will close an open modal
    });
  });

  $('#gist-it').on('click', function() {
    /* stop form from submitting normally */
    event.preventDefault();

    SassMeister.gist.save();
  });

  $('#reset').on('click', function() {
    event.preventDefault();

    SassMeister.reset();
  });


  $('select[name=plugin]').each(function() {
    $(this).dropdown({
      gutter : 0,
      speed : 25,
      onOptionSelect: function(opt) {
        var plugins = opt.data( 'value' );
        console.log(SassMeister.inputs.syntax);
        $.each(plugins.split(','), function(key, plugin) {
          SassMeister.inputs.sass.insert( '@import "' + plugin + '"' + ( SassMeister.inputs.syntax == 'scss' ? ';' : '' ) + '\n\n');
        });

      }
    })
  });
})(jQuery);
