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

    if($(this).attr("name").match(/syntax/)) {
      var inputs = {
        sass: SassMeister.inputs.sass.getValue(),
        syntax: $('select[name="syntax"]').val(),
        original_syntax: $('select[name="syntax"]').data('orignal'),
        plugin: $('select[name="plugin"]').val(),
        output: $('select[name="output"]').val()
      }

      $.post('/sass-convert', inputs,
        function( data ) {
          SassMeister.inputs.sass.setValue(data, -1);
        }
      );
    }
    else {
      $("#sass-form").submit();
    }
  });

  /* attach a submit handler to the form */
  $("#sass-form").submit(function(event) {
    event.preventDefault();

    SassMeister.compile.sass();
  });

  $('#html-form select').on('change', function() {
    _gaq.push(['_trackEvent', 'Form', 'Control', this.value]);

    if($(this).attr("name").match(/syntax/)) {
      var inputs = {
        html: SassMeister.inputs.html.getValue(),
        syntax: $('select[name="html-syntax"]').val()
      }

      $.post('/html-convert', inputs,
        function( data ) {
          SassMeister.inputs.html.setValue(data, -1);
        }
      );
    }
    else {
      $("#html-form").submit();
    }
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

    _gaq.push(['_trackEvent', 'Gist']);

    var inputs = {
      sass: SassMeister.inputs.sass.getValue(),
      syntax: $('select[name="syntax"]').val(),
      plugin: $('select[name="plugin"]').val(),
      output: $('select[name="output"]').val()
    }

    var action = '', confirmationText = 'is ready';

    if($('#gist-it').data('gist-save') == 'edit') {
      action = '/' + $('#gist-it').data('gist-save');
      confirmationText = 'has been updated';
    }

    ///* Send the data using post and put the results in a div */
    $.post('/gist' + action, inputs,
      function( data ) {
        SassMeister.modal('<a href="https://gist.github.com/' + data + '" target="_blank">Your Gist</a> ' + confirmationText + ', and here\'s the <a href="/gist/' + data + '">SassMeister live view.</a> ');

        var myNewState = {
        	data: { },
        	title: 'SassMeister | The Sass Playground!',
        	url: '/gist/' + data
        };
        history.pushState(myNewState.data, myNewState.title, myNewState.url);
        window.onpopstate = function(event){
          // console.log(event.state); // will be our state data, so myNewState.data
        }

        $('#gist-it').data('gist-save', 'edit');
      }
    );
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