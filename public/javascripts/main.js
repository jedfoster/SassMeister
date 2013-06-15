(function($) {
  
  var SassMeister = window.SassMeister.init();

  $("a[href^='http://'], a[href^='https://']").attr("target", "_blank");

  SassMeister.inputs.sass.getSession().on('change', function(e) {
    SassMeister.setTimer(SassMeister.timers.sass, SassMeister.compile.sass);
  });
  
  SassMeister.inputs.html.getSession().on('change', function(e) {
    SassMeister.setTimer(SassMeister.timers.html, SassMeister.compile.html);
  });

  $('#sass-form select').on('change', function() {
    _gaq.push(['_trackEvent', 'Form', 'Control', this.value]);

    SassMeister.convert.sass();
  });

  $('#html-form select').on('change', function() {
    _gaq.push(['_trackEvent', 'Form', 'Control', this.value]);

    SassMeister.convert.html();
  });

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
})(jQuery);