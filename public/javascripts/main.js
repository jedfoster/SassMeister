(function($) {
  var SassMeister = window.SassMeister.init();

  $("a[href^='http://'], a[href^='https://']").attr("target", "_blank");




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

  $('#save-gist').on('click', function() {
    /* stop form from submitting normally */
    event.preventDefault();

    SassMeister.gist[($(this).data('action'))]();
  });

  $('#reset').on('click', function() {
    event.preventDefault();

    SassMeister.reset();
  });


  
})(jQuery);
