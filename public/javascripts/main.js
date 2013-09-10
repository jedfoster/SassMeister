(function($) {
  document.domain = document.domain;
  
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
  
  // $('.panel').each(function(index) {
  //   foo = new Panel($(this).data('name'), {  });
  //   foo.show();
  // });

  $('#source').casement({split: 'vertical', onDrag: function(handle, event) {
    SassMeister.inputs.sass.resize();
    SassMeister.outputs.css.resize();
    SassMeister.inputs.html.resize();
  }});

  $('#casement').casement({split: 'horizontal', onDrag: function(handle, event) {
    SassMeister.inputs.sass.resize();
    SassMeister.outputs.css.resize();
    SassMeister.inputs.html.resize();
  }});
  
})(jQuery);
