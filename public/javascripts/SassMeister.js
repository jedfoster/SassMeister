var SassMeister;

(function($) {

  window.SassMeister = {
    init: function() {
      this.inputs.sass = ace.edit("sass");
      this.inputs.sass.setTheme("ace/theme/tomorrow");
      this.inputs.sass.getSession().setMode("ace/mode/scss");
      this.inputs.sass.focus();

      this.getStorage();

      this.inputs.syntax = $('select[name=syntax]').dropdown({
        gutter : 0,
        speed : 25,
        onOptionSelect: function(opt) {
          SassMeister.inputs.syntax = opt.data( 'value' );

          // _gaq.push(['_trackEvent', 'Form', 'Control', this.value]);

          SassMeister.convert.sass(true);
        }
      }).value();

      $('[name="syntax"]').data('orignal', SassMeister.inputs.syntax);

      this.inputs.output = $('select[name=output]').dropdown({
        gutter : 0,
        speed : 25,
        onOptionSelect: function(opt) {
          SassMeister.inputs.output = opt.data( 'value' );

          // _gaq.push(['_trackEvent', 'Form', 'Control', this.value]);

          SassMeister.compile.sass();
        }
      }).value();

      this.inputs.plugin = $('select[name=plugin]').dropdown({
          gutter : 0,
          speed : 25,
          onOptionSelect: function(opt) {
            var plugins = opt.data( 'value' );
            $.each(plugins.split(','), function(key, plugin) {
              SassMeister.inputs.sass.insert( '@import "' + plugin + '"' + ( SassMeister.inputs.syntax == 'scss' ? ';' : '' ) + '\n\n');
           });
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

      this.compile.sass();

      $(this.inputs.sass.getSession()).bindWithDelay('change', function(event) {
        if(SassMeister.internalValueChange == true) {
          SassMeister.internalValueChange = false;
        }
        else {
          SassMeister.compile.sass();
        }
      }, 750);

      return this;
    },

    inputs: {
      sass: '',
      syntax: '',
      plugin: '',
      output: ''
    },

    outputs: {
      css: ''
    },

    timer: null,

    compile: {
      sass: function() {
        var inputs = {
              sass: SassMeister.inputs.sass.getValue(),
              syntax: SassMeister.inputs.syntax,
              output: SassMeister.inputs.output
            };

        // _gaq.push(['_trackEvent', 'Form', 'Submit']);

        /* Post the form and handle the returned data */
        $.post('/compile', inputs, function( data ) {
          SassMeister.outputs.css.setValue(data,-1);

          $('[name="syntax"]').data('orignal', inputs.syntax);
        });

        SassMeister.setStorage(inputs);
      }
    },

    internalValueChange: false,

    toggleInternalValue: function(value) {
      SassMeister.internalValueChange = value;
    },
    internalValue: function(value) {
      return SassMeister.internalValueChange;
    },

    convert: {
      sass: function(convert_syntax) {
        if(convert_syntax == true) {
          var inputs = {
            sass: SassMeister.inputs.sass.getValue(),
            syntax: SassMeister.inputs.syntax,
            original_syntax: $('[name="syntax"]').data('orignal'),
            output: SassMeister.inputs.output
          }

          $.post('/convert', inputs, function( data ) {
            SassMeister.internalValueChange = true;

            SassMeister.inputs.sass.setValue(data, -1);

            $('[name="syntax"]').data('orignal', inputs.syntax);

            SassMeister.setStorage({
              sass: data,
              syntax: SassMeister.inputs.syntax,
              output: SassMeister.inputs.output
            });
          });
        }
        else {
          SassMeister.compile.sass();
        }
      }
    },

    gist: {
      save: function() {
        _gaq.push(['_trackEvent', 'Gist']);

        var inputs = {
          sass: SassMeister.inputs.sass.getValue(),
          syntax: SassMeister.inputs.syntax,
          plugin: [SassMeister.inputs.plugin],
          output: SassMeister.inputs.output
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
      $('#gist-it').text('').data('gist-save', '');

      SassMeister.inputs.sass.setValue('');
      SassMeister.outputs.css.setValue('');
      localStorage.clear();

      $.post('/reset');

      SassMeister.setUrl('/');
    },

    setUrl: function(url) {
      history.pushState({}, 'SassMeister | The Sass Playground!', url);
      window.onpopstate = function(event) {
        // console.log(event.state); // will be our state data, so {}
      }
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
      if(typeof(gist) !== "undefined" && gist.trim !== '') {
        SassMeister.storedInputs = gist;
      }
      else {
        SassMeister.storedInputs = JSON.parse(localStorage.getItem('inputs'));
      }

      if( SassMeister.storedInputs !== null) {
        SassMeister.inputs.sass.setValue(SassMeister.storedInputs.sass);
        SassMeister.inputs.sass.clearSelection();
        $('select[name="syntax"]').val(SassMeister.storedInputs.syntax).data('orignal', SassMeister.storedInputs.syntax);
        $('select[name="output"]').val(SassMeister.storedInputs.output);
        // $('select[name="html-syntax"]').val(this.storedInputs.html_syntax);
      }
    },

    setStorage: function(inputs) {
      var storage = SassMeister.storedInputs;

      storage = $.extend(storage, inputs);

      localStorage.setItem('inputs', JSON.stringify(storage));
    }
  };

})(jQuery);

