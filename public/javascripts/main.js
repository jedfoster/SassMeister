/*
bindWithDelay jQuery plugin
Author: Brian Grinstead
MIT license: http://www.opensource.org/licenses/mit-license.php

http://github.com/bgrins/bindWithDelay
*/
(function($) {
  $.fn.bindWithDelay = function( type, data, fn, timeout, throttle ) {
  	if ( $.isFunction( data ) ) {
  		throttle = timeout;
  		timeout = fn;
  		fn = data;
  		data = undefined;
  	}

  	// Allow delayed function to be removed with fn in unbind function
  	fn.guid = fn.guid || ($.guid && $.guid++);

  	// Bind each separately so that each element has its own delay
  	return this.each(function() {
      var wait = null;

      function cb() {
        var e = $.extend(true, { }, arguments[0]);
        var ctx = this;
        var throttler = function() {
        	wait = null;
        	fn.apply(ctx, [e]);
        };

        if (!throttle) { clearTimeout(wait); wait = null; }
        if (!wait) { wait = setTimeout(throttler, timeout); }
      }

      cb.guid = fn.guid;

      $(this).bind(type, data, cb);
  	});
  }
})(jQuery);
/* --- END bindWithDelay --- */


(function($) {
  var sass = ace.edit("sass");
  sass.setTheme("ace/theme/dawn");
  sass.getSession().setMode("ace/mode/scss");
  sass.focus();

  var css = ace.edit("css");
  css.setTheme("ace/theme/dawn");
  css.setReadOnly(true);
  css.getSession().$useWorker=false
  css.getSession().setMode("ace/mode/css");

  $("a[href^='http://'], a[href^='https://']").attr("target", "_blank");

  var timer;
  sass.getSession().on('change', function(e) {
    clearTimeout(timer);
    timer = setTimeout(function() {$("#sass-form").submit();}, 750);
  });

  $('select').on('change', function() {
    _gaq.push(['_trackEvent', 'Form', 'Control', this.value]);
    $("#sass-form").submit();
  });

  $("#sass-form").on('click', function() {
    //$('html, body').animate({
    //  scrollTop: $("#sass-form").offset().top - 10
    //}, 250);
  });

  /* attach a submit handler to the form */
  $("#sass-form").submit(function(event) {
    event.preventDefault();

    _gaq.push(['_trackEvent', 'Form', 'Submit']);

    var inputs = {
      sass: sass.getValue(),
      syntax: $('select[name="syntax"]').val(),
      plugin: $('select[name="plugin"]').val(),
      output: $('select[name="output"]').val()
    }

    /* Post the form and handle the returned data */
    $.post($(this).attr('action'), inputs,
      function( data ) {
        css.setValue(data,-1);
      }
    );

   localStorage.setItem('inputs', JSON.stringify(inputs));
  });

  var storedInputs = JSON.parse(localStorage.getItem('inputs'));

  if( storedInputs !== null) {
    sass.setValue(storedInputs.sass);
    sass.clearSelection();
    $('select[name="syntax"]').val(storedInputs.syntax);
    $('select[name="plugin"]').val(storedInputs.plugin);
    $('select[name="output"]').val(storedInputs.output);
    $("#sass-form").submit();
  }

  function setHeight() {
    console.log($("html").height());
    
    if ($("html").width() > 50 * 18) {
      var html = $("html").height(), header = $(".site_header").height() * 3, footer = $(".site_footer").height() * 3, controls = $('.sass_input .controls').height() * -1.5;

      $('.pre_container, .ace_scroller').css('height', html - header - footer - controls);
    }

    else {
      $('.pre_container, .ace_scroller').css('height', 480);
    }
  }

  setHeight();

  $(window).resize(setHeight);

  var buildModal = function(content) {
    if ($('#modal').length == 0) {
      $('body').append('<div class="controls_container reveal-modal large" id="modal"><a href="#" class="close-icon"><span class="alt">&#215;</span></a><span class="content">' + content + '</span></div>');
    }
    else {
      $('#modal .content').empty();
      $('#modal .content').append(content);
    }

    $('#modal').reveal({
      animation: 'fade', //fade, fadeAndPop, none
      animationSpeed: 100, //how fast animations are
      closeOnBackgroundClick: true, //if you click background will modal close?
      dismissModalClass: 'close-icon' //the class of a button or element that will close an open modal
    });
  }

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

    var action = '', confirmationText = 'Your Gist is ready.';

    if($('#gist-it').data('gist-save') == 'edit') {
      action = '/' + $('#gist-it').data('gist-save');
      confirmationText = 'Your Gist has been updated.';
    }
console.log('/gist' + action);
    ///* Send the data using post and put the results in a div */
    $.post('/gist' + action, inputs,
      function( data ) {
        buildModal(confirmationText + ' <a href="' + data + '" target="_blank">See it here.<a>');

        $('#gist-it').data('gist-save', 'edit');
      }
    );
  });
  
  $('#reset').on('click', function() {
    event.preventDefault();
    
    // console.log($("#sass-form select")); 
    $("#sass-form").get(0).reset();
    
    console.log($('#gist-it').data('gist-save'));
    
    $('#gist-it').data('gist-save', '');
    // console.log(sass);
    
    console.log($('#gist-it').data('gist-save'));
    sass.setValue('');
    css.setValue('');
    
  });
})(jQuery);