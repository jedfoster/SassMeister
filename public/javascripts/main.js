(function($) {
  var SassMeister = window.SassMeister.init();

  $("a[href^='http://'], a[href^='https://']").attr("target", "_blank");

  $('#save-gist').on('click', function(event) {
    /* stop form from submitting normally */
    event.preventDefault();

    SassMeister.gist[($(this).data('action'))]();
  });

  $('#reset').on('click', function(event) {
    event.preventDefault();

    SassMeister.reset();
  });
  
})(jQuery);
