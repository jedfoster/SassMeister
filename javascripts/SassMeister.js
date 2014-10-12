var SassMeister;

(function($) {
  function getHashParam(param) {
    var query = window.location.hash.substring(1);
    var vars = query.split(",");
    for (var i=0;i<vars.length;i++) {
      var pair = vars[i].split("=");
      if(pair[0] == param){
        return pair[1];
      }
    }
    return(false);
  }

  window.SassMeister = {
    _default: {
      inputs: {
        sass: {
          input: '',
          compiler: '3.4',
          syntax: 'SCSS',
          original_syntax: 'SCSS',
          output_style: 'expanded',
          dependencies: {}
        },
        html: {
          input: '',
          syntax: 'HTML'
        }
      },

      outputs: {
        css: '',
        html: ''
      },

      preferences: {
        theme: 'tomorrow',
        emmet: false,
        vim: false,
        scrollPastEnd: false
      }
    },

    inputs: null,

    outputs: null,

    preferences: null,

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

    ajaxCalls: {
      'getExtensions': false,
      'postCompileSass': false,
      'postConvertSass': false,
      'postCompileHtml': false,
      'postGistCreate': false,
      'postGistEdit': false,
      'postGistFork': false
    },

    init: function() {
      var fontSize;
      $this = this;

      this.inputs = this._default.inputs;
      this.outputs = this._default.outputs;
      this.preferences = this._default.preferences;

      if(fontSize = (getHashParam('font-size') * 100)) {
        $('head').append('<style>body { font-size: ' + fontSize + '%; }</style>');
      }

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
      //   d. rendered html
      //     d1. if no stored output, recompile

      // Sass
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


      // HTML (input only)
      this.editors.html = this.initEditor(this.inputs.html.input, 'html', this.inputs.html.syntax);

      $(this.editors.html.getSession()).bindWithDelay('change', function(event) {
        $this.inputs.html.input = $this.editors.html.getValue();
        $this.compile.html();
      }, 750);


      // CSS
      this.editors.css = this.initEditor(this.outputs.css, 'css', 'css');
      this.editors.css.setReadOnly(true);

      if(! this.editors.css.getValue()) {
        $this.compile.sass();
      }


      // Focus on the Sass input
      //this.editors.sass.focus();


      // HTML (rendered)
      if(this.outputs.html) {
        this.updateRender(this.outputs);
      }
      else if(this.inputs.html.input) {
        $this.compile.html();
      }


      // 3. arrange the panels
      // this.initControls();
      this.initPanels();
      this.arrangePanels(this.layout.orientation);

      $(window).on('resize', function(event) {
        SassMeister.arrangePanels(SassMeister.layout.orientation);
      });

      if(SassMeister.inputs.gist_id) {
        updateShareCode();
      }

      return this;
    },


    initControls: function() {
      $('#syntax').text(this.inputs.sass.syntax).data('original', this.inputs.sass.syntax);

      $('#output').text(this.inputs.sass.output_style);

      $('#html-syntax').text(this.inputs.html.syntax);
    },


    initPanels: function() {
      if(window.gist) {
        if(Modernizr.localstorage) {
          localStorage.removeItem('casementSettings');
        }

        if(!this.inputs.html.input) {
          this.layout.html = 'hide';
        }
        else {
          this.layout.html = 'show';
        }
      }

      if (this.layout.html == 'hide') {
        $('#rendered, [data-name="html"]').hide();
        $('#toggle_html').data("state", 'show').removeClass('show');
      }

      if (this.layout.css == 'hide') {
        $('[data-name="css"]').hide();
        $('#toggle_css').data("state", 'show').removeClass('show');
      }
    },


    initEditor: function(value, name, syntax) {
      var input = ace.edit(name),
          themeParam = getHashParam('theme'),
          theme = themeParam ? themeParam : this.preferences.theme;

      input.setTheme(theme);

      if(this.preferences.vim) {
        input.setKeyboardHandler("ace/keyboard/vim");
      }
      else {
        input.setKeyboardHandler(null);
      }

      input.setOption("enableEmmet", this.preferences.emmet);
      input.setOption("scrollPastEnd", this.preferences.scrollPastEnd);

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
        if(SassMeister.inputs.sass.input.trim()) {
          _gaq.push(['_trackEvent', 'Form', 'Submit']);

          $('#sass-compiling').removeClass('hide');
          $('#compile-time').text('').removeClass('fade');

          if(SassMeister.ajaxCalls.postCompileSass) {
            SassMeister.ajaxCalls.postCompileSass.abort();
          }

          /* Post the form and handle the returned data */
          SassMeister.ajaxCalls.postCompileSass = $.post('/app/' + SassMeister.inputs.sass.compiler + '/compile', SassMeister.inputs.sass)
            .done(function( data ) {
              SassMeister.editors.css.setValue(data.css,-1);
              SassMeister.outputs.css = data.css;
              SassMeister.inputs.sass.dependencies = data.dependencies;

              updateRender({
                css: data.css
              });

              SassMeister.setStorage();

              $('#sass-compiling').addClass('hide');
              $('#compile-time').text('Compiled in ' + data.time + 's').addClass('fade');
            })
            .always(function() {
              SassMeister.ajaxCalls.postCompileSass = false;
            });
        }
      },

      html: function() {
        if(SassMeister.inputs.html.input.trim()) {
          _gaq.push(['_trackEvent', 'Form', 'Submit']);

          if(SassMeister.inputs.html.syntax == 'HTML') {
            updateRender({
              css: SassMeister.outputs.css,
              html: SassMeister.inputs.html.input
            });

            SassMeister.outputs.html = SassMeister.inputs.html.input;
          }

          else if(SassMeister.inputs.html.syntax == 'Jade') {
            var jadeCompile = function(input) {
              data = window.jade.render(SassMeister.inputs.html.input, {pretty: true});

              updateRender({
                css: SassMeister.outputs.css,
                html: data
              });

              return data;
            };

            if(!window.jade) {
              $.ajax({
                url: '/js/jade.js',
                dataType: 'script',
                cache: true
              }).done(function() {
                SassMeister.outputs.html = jadeCompile(SassMeister.inputs.html.input);
              });
            }
            else {
              SassMeister.outputs.html = jadeCompile(SassMeister.inputs.html.input);
            }
          }

          else {
            if(SassMeister.ajaxCalls.postCompileHtml) {
              SassMeister.ajaxCalls.postCompileHtml.abort();
            }

            /* Post the form and handle the returned data */
            SassMeister.ajaxCalls.postCompileHtml = $.post(window.sandbox, SassMeister.inputs.html)
              .done(function( data ) {
                updateRender({
                  css: SassMeister.outputs.css,
                  html: data
                });

                SassMeister.outputs.html = data;
              })
              .always(function() {
                SassMeister.ajaxCalls.postCompileHtml = false;
              });
          }

          SassMeister.setStorage();
        }
      }
    },


    convert: {
      sass: function() {
        if(SassMeister.ajaxCalls.postConvertSass) {
          SassMeister.ajaxCalls.postConvertSass.abort();
        }

        /* Post the form and handle the returned data */
        SassMeister.ajaxCalls.postConvertSass = $.post('/app/' + SassMeister.inputs.sass.compiler + '/convert', SassMeister.inputs.sass)
          .done(function( data ) {
            SassMeister.bypassConversion = true;

            SassMeister.editors.sass.setValue(data.css, -1);

            SassMeister.inputs.sass.input = data.css;
            SassMeister.inputs.sass.original_syntax = SassMeister.inputs.sass.syntax
            SassMeister.inputs.sass.dependencies = data.dependencies;

            $('#syntax').data('original', SassMeister.inputs.sass.syntax);

            SassMeister.setStorage();
          })
          .always(function() {
            SassMeister.ajaxCalls.postConvertSass = false;
          });
      },
    },


    gist: {
      create: function() {
        _gaq.push(['_trackEvent', 'Gist', 'Create']);

        var confirmationText = 'is ready';

        var postData = {
          inputs: SassMeister.inputs,
          outputs: SassMeister.outputs
        };

        if(SassMeister.ajaxCalls.postGistCreate) {
          SassMeister.ajaxCalls.postGistCreate.abort();
        }

        ///* Send the data using post and put the results in a div */
        SassMeister.ajaxCalls.postGistCreate = $.post('/gist/create', postData)
          .done(function( data ) {
            modal('<a href="https://gist.github.com/' + data.id + '" target="_blank">Your Gist</a> ' + confirmationText + '.');

            setUrl('/gist/' + data.id);
            SassMeister.inputs.gist_id = data.id;
            SassMeister.inputs.sass_filename = data.sass_filename;
            SassMeister.inputs.html_filename = data.html_filename;

            $('#save-gist').data('action', 'edit').html('<span>Update Gist</span>');

            if($('#fork-gist').length < 1) {
              $('#save-gist').parent('li').after('<li><a id="fork-gist" class="fork-gist" data-action="create"><span>Fork Gist</span></a></li>');
            }

            if($('#gist-link').length < 1) {
              $('#cloud_actions li:first-child').after('<li><a href="https://gist.github.com/' + data.id + '" target="_blank" class="jump-icon" id="gist-link"><span>View on GitHub</span></a></li>');
            }

            updateShareCode();

            $('#share_actions').removeClass('hide');
          })
          .always(function() {
            SassMeister.ajaxCalls.postGistCreate = false;
          });
      },

      edit: function() {
        _gaq.push(['_trackEvent', 'Gist', 'Edit']);

        var postData = {
          inputs: SassMeister.inputs,
          outputs: SassMeister.outputs
        };

        var confirmationText = 'has been updated';

        if(SassMeister.ajaxCalls.postGistEdit) {
          SassMeister.ajaxCalls.postGistEdit.abort();
        }

        ///* Send the data using post and put the results in a div */
        SassMeister.ajaxCalls.postGistEdit = $.post('/gist/' + SassMeister.inputs.gist_id + '/edit', postData)
          .done(function( data ) {
            modal('<a href="https://gist.github.com/' + data.id + '" target="_blank">Your Gist</a> ' + confirmationText + '.');

            $('#gist-link').attr('href', 'https://gist.github.com/' + data.id);
            setUrl('/gist/' + data.id);
          })
          .always(function() {
            SassMeister.ajaxCalls.postGistEdit = false;
          });
      },

      fork: function() {
        _gaq.push(['_trackEvent', 'Gist', 'Fork']);

        var confirmationText = 'has been forked';

        if(SassMeister.ajaxCalls.postGistFork) {
          SassMeister.ajaxCalls.postGistFork.abort();
        }

        ///* Send the data using post and put the results in a div */
        SassMeister.ajaxCalls.postGistFork = $.post('/gist/' + SassMeister.inputs.gist_id + '/fork')
          .done(function( data ) {
            modal('<a href="https://gist.github.com/' + data.id + '" target="_blank">This Gist</a> ' + confirmationText + '.');

            $('#gist-link').attr('href', 'https://gist.github.com/' + data.id);
            setUrl('/gist/' + data.id);
            SassMeister.inputs.gist_id = data.id;

            updateShareCode();

            $('#save-gist').data('action', 'edit').attr('class', 'edit-gist').html('<span>Update Gist</span>');
          })
          .always(function() {
            SassMeister.ajaxCalls.postGistFork = false;
          });
      },
    },


    arrangePanels: function(orientation) {
      if(window.viewportSize == 'desktop' && $.fn.casement) {
        $('.panel, .current').removeClass('hide-panel').removeClass('show-panel').removeClass('current');
        $(document.body).removeClass('single-column');

        if (this.layout.html == 'hide') {
          $('#rendered, [data-name="html"]').hide();
          $('#toggle_html').data("state", 'show').addClass('show');
        }

        if (this.layout.css == 'hide') {
          $('#toggle_css').data("state", 'show').addClass('show');
        }

        // #source has to be done FIRST, since it is nested inside #casement. TODO: Fix this.
        $('#source').casement({
          split: (orientation == 'horizontal' ? 'vertical' : 'horizontal'),
          onDrag: function() {
          SassMeister.resizeEditors();
          }
        });

        $('#casement').casement({
          split: orientation,
          onDragStart: function() {
            $('#sash_cover').show();
          },
          onDrag: function() {
            SassMeister.resizeEditors();
          },
          onDragEnd: function() {
            $('#sash_cover').hide();
          }
        });
      }

      else {
        // Remove Casement, if it exists
        if($('#source .sash').length > 0) {
          $('#source').casement('destroy');
          $('#casement').casement('destroy');
        }

        if($('.hide-panel').length < 1 ) {
          $('.panel').removeClass('show-panel').addClass('hide-panel');
          $('[data-name="sass"]').removeClass('hide-panel').addClass('show-panel');
          $('#mobile-tabs .current').removeClass('current');
          $('[data-tab="sass"]').addClass('current');
          $(document.body).addClass('single-column');
        }
      }

      SassMeister.resizeEditors();
    },


    resizeEditors: function() {
      $.each(this.editors, function(i, editor) {
        editor.resize();
      });
    },


    setTheme: function(theme) {
      this.preferences.theme = theme;

      this.editors.sass.setTheme(theme);
      this.editors.css.setTheme(theme);
      this.editors.html.setTheme(theme);

      this.setStorage();
    },


    setEditorPreferences: function(key, value) {
      var $this = this;
      $this.preferences[key] = value;
      console.log(key, value);

      if($this.preferences.vim) {
        $this.editors.sass.setKeyboardHandler('ace/keyboard/vim');
        $this.editors.css.setKeyboardHandler('ace/keyboard/vim');
        $this.editors.html.setKeyboardHandler('ace/keyboard/vim');
      }
      else {
        $this.editors.sass.setKeyboardHandler(null);
        $this.editors.css.setKeyboardHandler(null);
        $this.editors.html.setKeyboardHandler(null);
      }

      if($this.preferences.emmet && !window.emmet) {
        $.ajax({
          url: 'http://nightwing.github.io/emmet-core/emmet.js',
          dataType: 'script',
          cache: true
        }).done(function() {
          $this.editors.sass.setOption('enableEmmet', true);
          $this.editors.css.setOption('enableEmmet', true);
          $this.editors.html.setOption('enableEmmet', true);
        });
      }
      else {
        $this.editors.sass.setOption('enableEmmet', $this.preferences.emmet);
        $this.editors.css.setOption('enableEmmet', $this.preferences.emmet);
        $this.editors.html.setOption('enableEmmet', $this.preferences.emmet);
      }

      if($this.preferences.scrollPastEnd) {
        $this.editors.sass.setOption('scrollPastEnd', true);
        $this.editors.css.setOption('scrollPastEnd', true);
        $this.editors.html.setOption('scrollPastEnd', true);
      }
      else {
        $this.editors.sass.setOption('scrollPastEnd', $this.preferences.scrollPastEnd);
        $this.editors.css.setOption('scrollPastEnd', $this.preferences.scrollPastEnd);
        $this.editors.html.setOption('scrollPastEnd', $this.preferences.scrollPastEnd);
      }

      $this.setStorage();
    },


    reset: function() {
      $('#save-gist').text('Save Gist').data('action', 'create');
      $('#share_actions').addClass('hide');

      this.editors.sass.setValue('');
      this.editors.css.setValue('');
      this.editors.html.setValue('');

      this.inputs = this._default.inputs;
      this.outputs = this._default.outputs;

      if(Modernizr.localstorage) {
        localStorage.clear();
      }

      updateRender({reset: true});

      setUrl('/');
    },


    getStorage: function() {
      if(window.gist) {
        this.inputs = $.extend(true, this.inputs, window.gist);

        if(this.inputs.sass.dependencies.libsass) {
          this.inputs.sass.compiler = 'lib';
          // this.inputs.sass.syntax = 'SCSS';
        }

        else if(this.inputs.sass.dependencies.Sass) {
          this.inputs.sass.compiler = this.inputs.sass.dependencies.Sass.slice(0, 3);
        }

        if(window.gist_output) {
          this.outputs = $.extend(true, this.outputs, window.gist_output);
        }
      }
      else {
        if(Modernizr.localstorage) {
          this.inputs = $.extend(true, this.inputs, JSON.parse(localStorage.getItem('inputs')) );
          this.outputs = $.extend(true, this.outputs, JSON.parse(localStorage.getItem('outputs')) );
        }
        else {
          this.inputs = $.extend(true, this.inputs, {} );
          this.outputs = $.extend(true, this.outputs, {} );
        }
        if(this.inputs.sass.dependencies.libsass) {
          this.inputs.sass.compiler = 'lib';
          // this.inputs.sass.syntax = 'SCSS';
        }

        else if(this.inputs.sass.dependencies.Sass) {
          this.inputs.sass.compiler = this.inputs.sass.dependencies.Sass.slice(0, 3);
        }
      }

      if(Modernizr.localstorage) {
        this.layout = $.extend(true, this.layout, JSON.parse(localStorage.getItem('layout')) );
        this.preferences = $.extend(true, this.preferences, JSON.parse(localStorage.getItem('preferences')) );
      }
      else {
        this.layout = $.extend(true, this.layout, {} );
        this.preferences = $.extend(true, this.preferences, {} );
      }

      switch(this.inputs.sass.syntax.toLowerCase()) {
        case 'sass':
          this.inputs.sass.syntax = 'Sass';
          break;
        case 'scss':
        default:
          this.inputs.sass.syntax = 'SCSS';
          break;
      }

      this.inputs.html.input = this.inputs.html.input.replace(/<\\+\/script>/g, '</script>');
      this.outputs.html = this.outputs.html.replace(/<\\+\/script>/g, '</script>');

      switch(this.inputs.html.syntax.toLowerCase()) {
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
        case 'jade':
          this.inputs.html.syntax = 'Jade';
          break;
        case 'html':
        default:
          this.inputs.html.syntax = 'HTML';
          break;
      }
    },


    setStorage: function() {
      if(! window.gist && Modernizr.localstorage) {
        localStorage.setItem('inputs', JSON.stringify( this.inputs ));
        localStorage.setItem('outputs', JSON.stringify( this.outputs ));
        localStorage.setItem('layout', JSON.stringify( this.layout ));
      }

      localStorage.setItem('preferences', JSON.stringify( this.preferences ));
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

  var updateShareCode = function() {
    var embedCode = '<p class="sassmeister" data-gist-id="' + SassMeister.inputs.gist_id + '" data-height="480" data-theme="' + SassMeister.preferences.theme + '"><a href="http://' + document.domain + '/gist/' + SassMeister.inputs.gist_id + '">Play with this gist on SassMeister.</a></p><script src="http://cdn.' + document.domain + '/js/embed.js" async></script>';

    $('#share_actions textarea').val(embedCode);

    // Update Twitter, if it's already been init'd
    if($('.twitter-share-button').attr('src')) {
      var parent = $('.twitter-share-button').parent();
      $('.twitter-share-button').remove();

      $(parent).prepend('<a href="https://twitter.com/share" class="twitter-share-button" data-text="Check out this sassy gist." data-url="http://' + document.domain + '/gist/' + SassMeister.inputs.gist_id + '" data-via="sassmeisterapp">Tweet</a>');
      twttr.widgets.load();
    }
  };

  var modal = function(content) {
    Messenger({ extraClasses: 'messenger-on-top' }).post({ message: content, hideAfter: 5, type: 'success' });
  };

})(jQuery);
