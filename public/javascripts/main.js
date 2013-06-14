(function($) {
  
  var SassMeister = $.fn.SassMeister();

  // console.log(SassMeister.inputs);

  $("a[href^='http://'], a[href^='https://']").attr("target", "_blank");

  // var sass_timer;
  SassMeister.inputs.sass.getSession().on('change', function(e) {
    clearTimeout(SassMeister.timers.sass);
    SassMeister.timers.sass = setTimeout(function() {$("#sass-form").submit();}, 750);
  });
  
  // var html_timer;
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

    _gaq.push(['_trackEvent', 'Form', 'Submit']);

    var inputs = {
      sass: SassMeister.inputs.sass.getValue(),
      syntax: $('select[name="syntax"]').val(),
      plugin: $('select[name="plugin"]').val(),
      output: $('select[name="output"]').val()
    }

    /* Post the form and handle the returned data */
    $.post($(this).attr('action'), inputs,
      function( data ) {
        SassMeister.outputs.css.setValue(data,-1);

        $('select[name="syntax"]').data('orignal', inputs.syntax);
        
          // console.log(data.sass);
        if(data.sass.length > 0) {
          
          SassMeister.inputs.sass.setValue(data.sass,-1);
        }
      }
    );

   localStorage.setItem('inputs', JSON.stringify(inputs));
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
  
    _gaq.push(['_trackEvent', 'Form', 'Submit']);
  
    var inputs = {
      html: SassMeister.inputs.html.getValue(),
      syntax: $('select[name="html-syntax"]').val()
    }
  
    /* Post the form and handle the returned data */
    $.post($(this).attr('action'), inputs,
      function( data ) {
        //console.log(data)
      }
    );
  
   // localStorage.setItem('inputs', JSON.stringify(inputs));
  });
  

  if($('#gist-input').text().length > 0) {
    var storedInputs = JSON.parse($('#gist-input').text());
  }
  else {
    var storedInputs = JSON.parse(localStorage.getItem('inputs'));
  }

  if( storedInputs !== null) {
    SassMeister.inputs.sass.setValue(storedInputs.sass);
    SassMeister.inputs.sass.clearSelection();
    $('select[name="syntax"]').val(storedInputs.syntax).data('orignal', storedInputs.syntax);
    $('select[name="plugin"]').val(storedInputs.plugin);
    $('select[name="output"]').val(storedInputs.output);
    $("#sass-form").submit();
  }

  function setHeight() {
    if ($("html").width() > 50 * 18) {
      var html = $("html").height(), header = $(".site_header").height(), footer = $(".site_footer").height(), controls = $('.sass_input .controls').height() + $('.sass_input .edit-header').height() + 52;

      $('.pre_container, .ace_scroller').css('height', html - header - footer - controls);
    }

    else {
      $('.pre_container, .ace_scroller').css('height', 480);
    }
  }

  $(window).resize(setHeight);

  var buildModal = function(content) {
    if ($('#modal').length == 0) {
      $('body').append('<div class="reveal-modal large" id="modal"><a href="#" class="close-icon"><span class="alt">&#215;</span></a><span class="content">' + content + '</span></div>');
    }
    else {
      $('#modal .content').empty();
      $('#modal .content').append(content);
    }

    $('#modal').reveal({
      animation: 'fadeAndPop', //fade, fadeAndPop, none
      animationSpeed: 250, //how fast animations are
      closeOnBackgroundClick: true, //if you click background will modal close?
      dismissModalClass: 'close-icon' //the class of a button or element that will close an open modal
    });
  }

  if ($("html").width() > 50 * 18) {
    $('#footer').addClass('reveal-modal large').prepend('<a href="#" class="close-icon"><span class="alt">&#215;</span></a>').hide();
  }

  $('#info, .logo').on('click', function() {
    event.preventDefault();

    $('#footer').reveal({
      animation: 'fadeAndPop', //fade, fadeAndPop, none
      animationSpeed: 250, //how fast animations are
      closeOnBackgroundClick: true, //if you click background will modal close?
      dismissModalClass: 'close-icon' //the class of a button or element that will close an open modal
    });
  });

  setHeight();

  $('#gist-it').on('click', function() {
    /* stop form from submitting normally */
    event.preventDefault();

    _gaq.push(['_trackEvent', 'Gist']);

    var inputs = {
      sass: sass.getValue(),
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
        buildModal('<a href="https://gist.github.com/' + data + '" target="_blank">Your Gist</a> ' + confirmationText + ', and here\'s the <a href="/gist/' + data + '">SassMeister live view.</a> ');

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