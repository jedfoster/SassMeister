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

  $("a[href^='http://'], a[href^='https://']").attr("target","_blank");


  var timer;
  sass.getSession().on('change', function(e) {
    clearTimeout(timer);
    timer = setTimeout(function() {$("#sass-form").submit();}, 750);
  });

  $('select').on('change', function() {
    _gaq.push(['_trackEvent', 'Form', 'Control', this.value]);
    $("#sass-form").submit();
  });


  /* attach a submit handler to the form */
  $("#sass-form").submit(function(event) {

    // var d = new Date();
    // console.log(d.getTime());

    /* stop form from submitting normally */
    event.preventDefault();

    _gaq.push(['_trackEvent', 'Form', 'Submit']);

    var inputs = {
      sass: sass.getValue(),
      syntax: $('select[name="syntax"]').val(),
      plugin: $('select[name="plugin"]').val(),
      output: $('select[name="output"]').val()
    }

    /* Send the data using post and put the results in a div */
    $.post($(this).attr('action'), inputs,
      function( data ) {
        css.setValue(data,-1);
      }
    );
  });

  $('#settings-toggle').on('click', function() {
    event.preventDefault();
    // $('#settings').reveal({
    //   animation: 'fade', //fade, fadeAndPop, none
    //   animationSpeed: 100, //how fast animations are
    //   closeOnBackgroundClick: true, //if you click background will modal close?
    //   dismissModalClass: 'close-icon' //the class of a button or element that will close an open modal
    // });
    
    $('#edit_controls2323').toggle();
  });

  var buildModal = function(content) {
    var modal = '<div class="controls_container reveal-modal large" id="modal"><a href="#" class="close-icon"><span class="alt">&#215;</span></a>' + content + '</div>';

    $('body').append($(modal));

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

    ///* Send the data using post and put the results in a div */
    $.post('/gist', inputs,
      function( data ) {
        buildModal('Your Gist is ready. <a href="' + data + '" target="_blank">See it here.<a>');
      }
    );
  });

  $('#gist-edit').on('click', function() {
    /* stop form from submitting normally */
    event.preventDefault();

    _gaq.push(['_trackEvent', 'Gist']);

    var inputs = {
      sass: sass.getValue(),
      syntax: $('select[name="syntax"]').val(),
      plugin: $('select[name="plugin"]').val(),
      output: $('select[name="output"]').val()
    }

    ///* Send the data using post and put the results in a div */
    $.post('/gist/edit', inputs,
      function( data ) {
        buildModal('Your Gist is ready. <a href="' + data + '" target="_blank">See it here.<a>');
      }
    );
  });
})(jQuery);