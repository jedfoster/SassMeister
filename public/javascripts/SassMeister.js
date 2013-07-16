var SassMeister;

(function($) {

  window.SassMeister = {
    init: function() {
      this.inputs.sass = ace.edit("sass");
      this.inputs.sass.setTheme("ace/theme/tomorrow");
      this.inputs.sass.getSession().setMode("ace/mode/scss");
      this.inputs.sass.focus();
      
      this.inputs.syntax = $('select[name=syntax]').dropdown({
        gutter : 0,
        speed : 25,
        onOptionSelect: function(opt) {
          SassMeister.inputs.syntax = opt.data( 'value' );
        }
      }).value();

      this.inputs.output = $('select[name=output]').dropdown({
        gutter : 0,
        speed : 25,
        onOptionSelect: function(opt) {
          SassMeister.inputs.output_style = opt.data( 'value' );
        }
      }).value();

      this.outputs.css = ace.edit("css");
      this.outputs.css.setTheme("ace/theme/tomorrow");
      this.outputs.css.setReadOnly(true);
      this.outputs.css.getSession().$useWorker=false
      this.outputs.css.getSession().setMode("ace/mode/css");

      $(window).resize(this.setHeight);

      if ($("html").width() > 50 * 18) {
        $('#footer').addClass('reveal-modal large').prepend('<a href="#" class="close-icon"><span class="alt">&#215;</span></a>').hide();
      }
      
      this.setHeight();

      this.getStorage();

      return this;
    },

    inputs: {
      sass: '',
      syntax: '',
      // original_syntax: '',
      output_style: '',
    },

    outputs: {
      css: '',
    },

    timers: {
      sass: '',
    },

    compile: {
      sass: function() {
        var inputs = {
              sass: SassMeister.inputs.sass.getValue(),
              syntax: SassMeister.inputs.syntax,
              output: SassMeister.inputs.output_style
            };

        _gaq.push(['_trackEvent', 'Form', 'Submit']);

        /* Post the form and handle the returned data */
        $.post('/compile', inputs,
          function( data ) {
            SassMeister.outputs.css.setValue(data,-1);

            $('select[name="syntax"]').data('orignal', inputs.syntax);
          }
        );

        SassMeister.setStorage(inputs);
      },

    convert: {
      sass: function() {
        if($('#sass-form select').attr("name").match(/syntax/)) {
          var inputs = {
            sass: SassMeister.inputs.sass.getValue(),
            syntax: SassMeister.inputs.syntax,
            original_syntax: $('select[name="syntax"]').data('orignal'),
            output: SassMeister.inputs.output_style
          }

          $.post('/convert', inputs,
            function( data ) {
              SassMeister.inputs.sass.setValue(data, -1);
            }
          );
        }
        else {
          SassMeister.compile.sass();
        }
      },
    },

    gist: {
      save: function() {
        _gaq.push(['_trackEvent', 'Gist']);

        var inputs = {
          sass: SassMeister.inputs.sass.getValue(),
          syntax: SassMeister.inputs.syntax,
          output: SassMeister.inputs.output_style
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

            SassMeister.setUrl('/gist/' + data);

            $('#gist-it').data('gist-save', 'edit');
          }
        );
      }
    },

    reset: function() {
      $("#sass-form").get(0).reset();
      $('#gist-it').data('gist-save', '');

      SassMeister.inputs.sass.setValue('');
      SassMeister.outputs.css.setValue('');

      $.post('/reset');

      SassMeister.setUrl('/');
    },

    setUrl: function(url) {
      history.pushState({}, 'SassMeister | The Sass Playground!', url);
      window.onpopstate = function(event) {
        // console.log(event.state); // will be our state data, so {}
      }
    },

    setTimer: function(timer, callback) {
      clearTimeout(timer);
      timer = setTimeout(function(){callback();}, 750);
    },

    modal: function(content) {
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
    },

    setHeight: function() {
      if ($("html").width() > 50 * 18) {
        var html = $("html").height(), header = $(".site_header").height(), footer = $(".site_footer").height(), controls = $('.sass_input .controls').height() + $('.sass_input .edit-header').height() + 52;

        $('.pre_container, .ace_scroller').css('height', html - header - footer - controls);
      }

      else {
        $('.pre_container, .ace_scroller').css('height', 480);
      }
    },

    storedInputs: null,

    getStorage: function() {
      if($('#gist-input').text().length > 0) {
        this.storedInputs = JSON.parse($('#gist-input').text());
      }
      else {
        this.storedInputs = JSON.parse(localStorage.getItem('inputs'));
      }

      if( this.storedInputs !== null) {
        // console.log(this.storedInputs);
        this.inputs.sass.setValue(this.storedInputs.sass);
        this.inputs.sass.clearSelection();

        // console.log(this.inputs.sass.getValue());

        $('select[name="syntax"]').val(this.storedInputs.syntax).data('orignal', this.storedInputs.syntax);
        $('select[name="plugin"]').val(this.storedInputs.plugin);
        $('select[name="output"]').val(this.storedInputs.output);
        // $('select[name="html-syntax"]').val(this.storedInputs.html_syntax);
        // this.compile.sass();
      }
    },

    setStorage: function(inputs) {
      var storage = SassMeister.storedInputs;
      $.extend(storage, inputs)

      localStorage.setItem('inputs', JSON.stringify(storage));
    },
  };

})(jQuery);

