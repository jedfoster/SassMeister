var SassMeister;

(function($) {

  window.SassMeister = {
    _default: {
      inputs: {
        sass: {
          input: '',
          syntax: 'SCSS',
          original_syntax: 'SCSS',
          output_style: 'expanded'
        },
        html: {
          input: '',
          syntax: 'HTML'
        }
      },

      outputs: {
        css: '',
        html: ''
      }
    },

    inputs: null,

    outputs: null,

    editors: {
      sass: null,
      css: null,
      html: null
    },

    layout: {
      orientation: 'horizontal',
      html: 'hide',
      css: 'show'
    },

    timer: null,

    bypassConversion: false,

    init: function() {
      $this = this;

      this.inputs = this._default.inputs;
      this.outputs = this._default.outputs;


      // Process:
      //
      // 1. retreive stored inputs and outputs
      //   a. if gist ... do something
      //   b. else ... do something else

      this.getStorage();


      // 2. set up editors
      //   a. sass
      //   b. html
      //   c. css
      //     c1. if no stored output, recompile
      this.editors.sass = this.initEditor(this.inputs.sass.input, 'sass', this.inputs.sass.syntax);

      $(this.editors.sass.getSession()).bindWithDelay('change', function(event) {
        if($this.bypassConversion == true) {
          $this.bypassConversion = false;
        }
        else {
          $this.inputs.sass.input = $this.editors.sass.getValue();
          $this.compile.sass();
        }
      }, 750);


      this.editors.html = this.initEditor(this.inputs.html.input, 'html', this.inputs.html.syntax);

      $(this.editors.html.getSession()).bindWithDelay('change', function(event) {
        $this.inputs.html.input = $this.editors.html.getValue();
        $this.compile.html();
      }, 750);


      this.editors.css = this.initEditor(this.outputs.css.input, 'css', 'css');
      this.editors.css.setReadOnly(true);

      if(! this.editors.css.getValue()) {
        $this.compile.sass();
      }

      // Focus on the Sass input
      this.editors.sass.focus();



      // 3. arrange the panels
      this.initControls();
      this.initPanels();
      this.arrangePanels(this.layout.orientation);

      return this;
    },


    initControls: function() {
      $('#syntax').text(this.inputs.sass.syntax).data('original', this.inputs.sass.syntax);

      $('#output').text(this.inputs.sass.output_style);

      $('#html-syntax').text(this.inputs.html.syntax);
    },


    initPanels: function() {
      if(window.gist) {
        localStorage.removeItem('casementSettings');
        
        if(!this.inputs.html.input) {
          this.layout.html = 'hide';
        }
        else {
          this.layout.html = 'show';
        }
      } 

      if (this.layout.html == 'hide') {
        $('#rendered, [data-name="html"]').hide();
        $('#toggle_html').data("state", 'show').toggleClass('show');
      }

      if (this.layout.css == 'hide') {
        $('[data-name="css"]').hide();
        $('#toggle_css').data("state", 'show').toggleClass('show');
      }
    },


    initEditor: function(value, name, syntax) {
      var input = ace.edit(name);

      input.setTheme('ace/theme/tomorrow');
      input.getSession().setMode('ace/mode/' + syntax.toLowerCase());
      
      input.getSession().setTabSize(2);
      input.getSession().setUseSoftTabs(true);

      input.setValue(value);
      input.clearSelection();
      return input;
    },


    updateRender: function(new_content) {
      return updateRender(new_content);
    },

    compile: {
      sass: function() {
        // _gaq.push(['_trackEvent', 'Form', 'Submit']);

        /* Post the form and handle the returned data */
        $.post('/compile', SassMeister.inputs.sass, function( data ) {
          SassMeister.editors.css.setValue(data,-1);
          SassMeister.outputs.css = data;

          updateRender({
            css: data
          });

          SassMeister.setStorage();
        });
      },

      html: function() {
        // _gaq.push(['_trackEvent', 'Form', 'Submit']);

        if(SassMeister.inputs.html.syntax == 'HTML') {
          updateRender({
            css: SassMeister.outputs.css,
            html: SassMeister.inputs.html.input
          });

          SassMeister.outputs.html = SassMeister.inputs.html.input;
        }

        else {
          /* Post the form and handle the returned data */
          $.post(window.sandbox, SassMeister.inputs.html, function( data ) {
            updateRender({
              css: SassMeister.outputs.css,
              html: data
            });

            SassMeister.outputs.html = data;
          });
        }

        SassMeister.setStorage();
      }
    },


    convert: {
      sass: function() {
        $.post('/convert', SassMeister.inputs.sass, function( data ) {
          SassMeister.bypassConversion = true;

          SassMeister.editors.sass.setValue(data, -1);

          SassMeister.inputs.sass.original_syntax = SassMeister.inputs.sass.syntax

          $('#syntax').data('original', SassMeister.inputs.sass.syntax);

          SassMeister.setStorage();
        });
      },
    },


    gist: {
      create: function() {
        // _gaq.push(['_trackEvent', 'Gist']);

        var confirmationText = 'is ready';

        var postData = {
          inputs: SassMeister.inputs,
          outputs: SassMeister.outputs
        };

        ///* Send the data using post and put the results in a div */
        $.post('/gist/create', postData, function( data ) {
          modal('<a href="https://gist.github.com/' + data.id + '" target="_blank">Your Gist</a> ' + confirmationText + ', and here\'s the <a href="/gist/' + data.id + '">SassMeister live view.</a> ');

          setUrl('/gist/' + data.id);
          SassMeister.inputs.gist_id = data.id;
          SassMeister.inputs.sass_filename = data.sass_filename;
          SassMeister.inputs.html_filename = data.html_filename;

          $('#save-gist').text('Update Gist').data('action', 'edit');
        });
      },

      edit: function() {
        // _gaq.push(['_trackEvent', 'Gist']);

        var postData = {
          inputs: SassMeister.inputs,
          outputs: SassMeister.outputs
        };

        var confirmationText = 'has been updated';

        ///* Send the data using post and put the results in a div */
        $.post('/gist/' + SassMeister.inputs.gist_id + '/edit', postData, function( data ) {
          modal('<a href="https://gist.github.com/' + data.id + '" target="_blank">Your Gist</a> ' + confirmationText + ', and here\'s the <a href="/gist/' + data.id + '">SassMeister live view.</a> ');

          setUrl('/gist/' + data.id);
        });
      },

      fork: function() {
        _gaq.push(['_trackEvent', 'Gist']);

        var confirmationText = 'has been forked';

        ///* Send the data using post and put the results in a div */
        $.post('/gist/' + SassMeister.inputs.gist_id + '/fork', function( data ) {
          modal('<a href="https://gist.github.com/' + data.id + '" target="_blank">This Gist</a> ' + confirmationText + ', and here\'s the <a href="/gist/' + data.id + '">SassMeister live view.</a> ');

          setUrl('/gist/' + data.id);
          // SassMeister.storedInputs.gist_id = data.id;

          $('#save-gist').text('Update Gist').data('action', 'edit').attr('class', 'edit-gist');
        });
      },
    },


    arrangePanels: function(orientation) {
      // #source has to be done FIRST, since it is nested inside #casement. TODO: Fix this.
      $('#source').casement({
        split: (orientation == 'horizontal' ? 'vertical' : 'horizontal'),
        onDrag: function() {
          SassMeister.editors.sass.resize();
          SassMeister.editors.html.resize();
          SassMeister.editors.css.resize();
        }
      });

      $('#casement').casement({
        split: orientation,
        onDragStart: function() {
          $('#sash_cover').show();
        },
        onDrag: function() {
          SassMeister.editors.sass.resize();
          SassMeister.editors.html.resize();
          SassMeister.editors.css.resize();
        },
        onDragEnd: function() {
          $('#sash_cover').hide();
        }
      });

      SassMeister.editors.sass.resize();
      SassMeister.editors.html.resize();
      SassMeister.editors.css.resize();
    },


    reset: function() {
      $('#save-gist').text('Save Gist').data('action', 'create');

      this.editors.sass.setValue('');
      this.editors.css.setValue('');
      this.editors.html.setValue('');

      this.inputs = this._default.inputs;
      this.outputs = this._default.outputs;

      localStorage.clear();

      updateRender({reset: true});

      setUrl('/');
    },


    getStorage: function() {
      if(window.gist) {
        this.inputs = $.extend(true, this.inputs, window.gist);
      }
      else {
        if(window.resetApp) {
          localStorage.removeItem('inputs');
          localStorage.removeItem('outputs');
        }
        
        this.inputs = $.extend(true, this.inputs, JSON.parse(localStorage.getItem('inputs')) );
        this.outputs = $.extend(true, this.outputs, JSON.parse(localStorage.getItem('outputs')) );
      }

      this.layout = $.extend(true, this.layout, JSON.parse(localStorage.getItem('layout')) );

      switch (this.inputs.sass.syntax.toLowerCase()) {
        case 'sass':
          this.inputs.sass.syntax = 'Sass';
          break;
        case 'scss':
        default:
          this.inputs.sass.syntax = 'SCSS';
          break;
      }

      switch (this.inputs.html.syntax.toLowerCase()) {
        case 'haml':
          this.inputs.html.syntax = 'Haml';
          break;
        case 'slim':
          this.inputs.html.syntax = 'Slim';
          break;
        case 'markdown':
          this.inputs.html.syntax = 'Markdown';
          break;
        case 'textile':
          this.inputs.html.syntax = 'Textile';
          break;
        case 'html':
        default:
          this.inputs.html.syntax = 'HTML';
          break;
      }
    },


    setStorage: function() {
      if(! window.gist) {
        localStorage.setItem('inputs', JSON.stringify( this.inputs ));
        localStorage.setItem('outputs', JSON.stringify( this.outputs ));
        localStorage.setItem('layout', JSON.stringify( this.layout ));
      }
    }
  };


  var updateRender = function(new_content) {
    $('#rendered-html')[0].contentWindow.postMessage(JSON.stringify(new_content), '*');
  };

  var setUrl = function(url) {
    history.pushState({}, 'SassMeister | The Sass Playground!', url);
    window.onpopstate = function(event) {
      // console.log(event.state); // will be our state data, so {}
    }
  };


  var modal = function(content) {
    if ($('#modal').length == 0) {
      $('body').append('<div class="reveal-modal large" id="modal"><a class="close-icon"><span class="alt">&#215;</span></a><span class="content">' + content + '</span></div>');
    }
    else {
      $('#modal .content').empty().append(content);
    }

    $('#modal').reveal({
      animation: 'fadeAndPop', //fade, fadeAndPop, none
      animationSpeed: 250, //how fast animations are
      closeOnBackgroundClick: true, //if you click background will modal close?
      dismissModalClass: 'close-icon' //the class of a button or element that will close an open modal
    });
  };

})(jQuery);
