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

  $('#toggle_html').on('click', function(event) {
    event.preventDefault();

    var state = $(this).data("state")

    SassMeister.toggleHTMLPanels(state);

    if(state == 'hide') {
      $(this).data("state", 'show').toggleClass('show').find('span').text('Show HTML');
    }
    else {
      $(this).data("state", 'hide').toggleClass('show').find('span').text('Hide HTML');
    }
  });

  window.onmessage = function (event) {
    if (SassMeister.html == 'show') {
      if(SassMeister.storedOutputs.html) {
        SassMeister.updateRender(SassMeister.storedOutputs);
      }
      else {
        SassMeister.convert.html();
      }
    }
  };

})(jQuery);
