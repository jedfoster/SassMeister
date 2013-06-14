(function($) {
  
  var SassMeister = window.SassMeister.init();

  $("a[href^='http://'], a[href^='https://']").attr("target", "_blank");

  SassMeister.inputs.sass.getSession().on('change', function(e) {
    clearTimeout(SassMeister.timers.sass);
    SassMeister.timers.sass = setTimeout(function() {$("#sass-form").submit();}, 750);
  });
  
  SassMeister.inputs.html.getSession().on('change', function(e) {
    clearTimeout(SassMeister.timers.html);
    SassMeister.timers.html = setTimeout(function() {$("#html-form").submit();}, 750);
  });

  $('#sass-form select').on('change', function() {
    _gaq.push(['_trackEvent', 'Form', 'Control', this.value]);

    SassMeister.convert.sass();
  });

  /* attach a submit handler to the form */
  $("#sass-form").submit(function(event) {
    event.preventDefault();

    SassMeister.compile.sass();
  });

  $('#html-form select').on('change', function() {
    _gaq.push(['_trackEvent', 'Form', 'Control', this.value]);

    SassMeister.convert.html();
  });

  /* attach a submit handler to the form */
  $("#html-form").submit(function(event) {
    event.preventDefault();
  
    SassMeister.compile.html();
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

    $("#sass-form").get(0).reset();
    $('#gist-it').data('gist-save', '');

    sass.setValue('');
    css.setValue('');

    $.post('/reset');

    var myNewState = {
    	data: { },
    	title: 'SassMeister | The Sass Playground!',
    	url: '/'
    };
    history.pushState(myNewState.data, myNewState.title, myNewState.url);
    window.onpopstate = function(event){
      // console.log(event.state); // will be our state data, so myNewState.data
    }
  });
})(jQuery);