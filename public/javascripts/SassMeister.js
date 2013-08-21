var SassMeister;

(function($) {

  window.SassMeister = {
    init: function() {
      this.inputs.sass = ace.edit("sass");
      this.inputs.sass.setTheme("ace/theme/tomorrow");
      this.inputs.sass.getSession().setMode("ace/mode/scss");
      this.inputs.sass.focus();

      this.getStorage();

      if($('#save-gist')) {
        if(this.storedInputs !== null && this.storedInputs.gist_id !== null) {
          if (this.storedInputs.can_update_gist !== null) {
            $('#save-gist').text('Update Gist').data('action', 'edit').attr('class', 'edit-gist');
          }
          else {
            $('#save-gist').text('Fork Gist').data('action', 'fork').attr('class', 'fork-gist');
          }
        }

        else {
          $('#save-gist').text('Save Gist').data('action', 'create').attr('class', 'create-gist');
        }
      }     

      this.inputs.syntax = $('select[name=syntax]').minimalect({
        empty: '',
        theme: 'bubble',
        onchange: function(value, text) {
          SassMeister.inputs.syntax = value;
      
          // _gaq.push(['_trackEvent', 'Form', 'Control', this.value]);
      
          SassMeister.convert.sass(true);
        }
      }).val();
      
      $('[name="syntax"]').data('original', SassMeister.inputs.syntax);
      
      this.inputs.output = $('select[name=output]').minimalect({
        empty: '',
        theme: 'bubble',
        onchange: function(value, text) {
          SassMeister.inputs.output = value;
      
          // _gaq.push(['_trackEvent', 'Form', 'Control', this.value]);
      
          SassMeister.compile.sass();
        }
      }).val();
      
      this.inputs.plugin = $('select[name=plugin]').minimalect({
        empty: '',
        theme: 'bubble',
        onfilter: function(match) {
          console.log(match);
        },
        onchange: function(value, text) {
          var plugins = value;
          $.each(plugins.split(','), function(key, plugin) {
            SassMeister.inputs.sass.insert( '@import "' + plugin + '"' + ( SassMeister.inputs.syntax == 'scss' ? ';' : '' ) + '\n\n');
          });
        }
      }).val();

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

          $('[name="syntax"]').data('original', inputs.syntax);
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
            original_syntax: $('[name="syntax"]').data('original'),
            output: SassMeister.inputs.output
          }

          $.post('/convert', inputs, function( data ) {
            SassMeister.internalValueChange = true;

            SassMeister.inputs.sass.setValue(data, -1);

            $('[name="syntax"]').data('original', inputs.syntax);

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
      create: function() {
        _gaq.push(['_trackEvent', 'Gist']);

        var inputs = {
          sass: SassMeister.inputs.sass.getValue(),
          syntax: SassMeister.inputs.syntax,
          output: SassMeister.inputs.output
        }

        var confirmationText = 'is ready';

        ///* Send the data using post and put the results in a div */
        $.post('/gist/create', inputs, function( data ) {
          SassMeister.modal('<a href="https://gist.github.com/' + data.id + '" target="_blank">Your Gist</a> ' + confirmationText + ', and here\'s the <a href="/gist/' + data.id + '">SassMeister live view.</a> ');

          SassMeister.setUrl('/gist/' + data.id);
          SassMeister.storedInputs.gist_id = data.id;
          SassMeister.storedInputs.gist_filename = data.filename;

          $('#save-gist').text('Update Gist').data('action', 'edit');
        });
      },

      edit: function() {
        _gaq.push(['_trackEvent', 'Gist']);

        var inputs = {
          sass: SassMeister.inputs.sass.getValue(),
          syntax: SassMeister.inputs.syntax,
          output: SassMeister.inputs.output,
          gist_filename: SassMeister.storedInputs.gist_filename
        }

        var confirmationText = 'has been updated';

        ///* Send the data using post and put the results in a div */
        $.post('/gist/' + SassMeister.storedInputs.gist_id + '/edit', inputs, function( data ) {
          SassMeister.modal('<a href="https://gist.github.com/' + data.id + '" target="_blank">Your Gist</a> ' + confirmationText + ', and here\'s the <a href="/gist/' + data.id + '">SassMeister live view.</a> ');

          SassMeister.setUrl('/gist/' + data.id);
          SassMeister.storedInputs.gist_filename = data.filename;
        });
      },

      fork: function() {
        _gaq.push(['_trackEvent', 'Gist']);

        var confirmationText = 'has been forked';

        ///* Send the data using post and put the results in a div */
        $.post('/gist/' + SassMeister.storedInputs.gist_id + '/fork', function( data ) {
          SassMeister.modal('<a href="https://gist.github.com/' + data.id + '" target="_blank">This Gist</a> ' + confirmationText + ', and here\'s the <a href="/gist/' + data.id + '">SassMeister live view.</a> ');

          SassMeister.setUrl('/gist/' + data.id);
          SassMeister.storedInputs.gist_id = data.id;

          $('#save-gist').text('Update Gist').data('action', 'edit').attr('class', 'edit-gist');
        });
      },
    },

    reset: function() {
      $("#sass-form").get(0).reset();
      $('#save-gist').text('Save Gist').data('action', 'create');

      SassMeister.inputs.sass.setValue('');
      SassMeister.outputs.css.setValue('');
      localStorage.clear();
      SassMeister.storedInputs = {},

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
      // if ($("html").width() > 50 * 18) {
      //   var html = $("html").height(), header = $(".site_header").height(), footer = $(".site_footer").height(), controls = $('.sass_input .controls').height() + $('.sass_input .edit-header').height() + 52;
      // 
      //   $('.pre_container, .ace_scroller').css('height', html - header - footer - controls);
      // }
      // 
      // else {
      //   $('.pre_container, .ace_scroller').css('height', 480);
      // }
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
        $('select[name="syntax"]').val(SassMeister.storedInputs.syntax).data('original', SassMeister.storedInputs.syntax);
        $('select[name="output"]').val(SassMeister.storedInputs.output);
        // $('select[name="html-syntax"]').val(this.storedInputs.html_syntax);
      }
    },

    setStorage: function(inputs) {
      localStorage.setItem('inputs', JSON.stringify( $.extend(SassMeister.storedInputs, inputs) ));
    }
  };

})(jQuery);

