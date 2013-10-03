var SassMeister;

(function($) {

  window.SassMeister = {
    inputs: {
      sass: {
        input: ".box\n\twidth: 5em\n\theight: 5em \n\tbackground: blue", // null
        syntax: 'SCSS',
        original_syntax: 'SCSS',
        output_style: 'expanded'
      },
      html: {
        input: "<div class=\"box\"></div>", //null,
        syntax: 'HTML'
      }
    },

    outputs: {
      css: '', //".box {\n\twidth: 5em; \n\theight: 5em; \n\tbackground: blue; \n}",
      html: ''
    },

    editors: {
      sass: null,
      css: null,
      html: null
    },

    layout: {
      orientation: 'horizontal',
      html: 'show',
      css: 'show'
    },

    timer: null,

    bypassConversion: false,

    init: function() {
      $this = this;
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
      this.editors.css.getSession().$useWorker = false;

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
      if (this.layout.html == 'hide') {
        $('#rendered, #html_input').hide();
        $('#toggle_html').data("state", 'show').toggleClass('show');
      }

      if (this.layout.css == 'hide') {
        $('#css_input').hide();
        $('#toggle_css').data("state", 'show').toggleClass('show');
      }
    },


    initEditor: function(value, name, syntax) {
      var input = ace.edit(name);

      input.setTheme('ace/theme/tomorrow');
      input.getSession().setMode('ace/mode/' + syntax.toLowerCase());

      input.setValue(value);
      input.clearSelection();
      return input;
    },

    compile: {
      sass: function() {
        // _gaq.push(['_trackEvent', 'Form', 'Submit']);

        /* Post the form and handle the returned data */
        $.post('/compile', SassMeister.inputs.sass, function( data ) {
          SassMeister.editors.css.setValue(data,-1);
          SassMeister.outputs.css = data;
          
          // $('#syntax').data('original', SassMeister.inputs.sass.syntax);

          SassMeister.updateRender({
            css: data
          });

          // SassMeister.setStorage(inputs, {css: data});
          SassMeister.setStorage();
        });
      },

      html: function() {
        // _gaq.push(['_trackEvent', 'Form', 'Submit']);
      
        if(SassMeister.inputs.html.syntax == 'HTML') {
          SassMeister.updateRender({
            css: SassMeister.outputs.css,
            html: SassMeister.inputs.html.input
          });
          
          SassMeister.outputs.html = SassMeister.inputs.html.input;
        }
      
        else {
          /* Post the form and handle the returned data */
          $.post(window.sandbox, SassMeister.inputs.html, function( data ) {
            SassMeister.bypassConversion = true;
      
            SassMeister.updateRender({
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

    updateRender: function(new_content) {
      $('#rendered-html')[0].contentWindow.postMessage(JSON.stringify(new_content), '*');
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
    },
    
    
    getStorage: function() {
      if(window.gist) {
        this.inputs = $.extend(this.inputs, window.gist);
      }
      else {
        this.inputs = $.extend(this.inputs, JSON.parse(localStorage.getItem('inputs')) );
        this.outputs = $.extend(this.outputs, JSON.parse(localStorage.getItem('outputs')) );
      }
      

      console.log(SassMeister.inputs.sass.syntax);

      switch (SassMeister.inputs.sass.syntax.toLowerCase()) {
        case 'sass':
          SassMeister.inputs.sass.syntax = 'Sass';
          break;
        case 'scss':
        default:
          SassMeister.inputs.sass.syntax = 'SCSS';
          break;
      }
    
      switch (SassMeister.inputs.html.syntax.toLowerCase()) {
        case 'haml':
          SassMeister.inputs.html.syntax = 'Haml';
          break;
        case 'slim':
          SassMeister.inputs.html.syntax = 'Slim';
          break;
        case 'markdown':
          SassMeister.inputs.html.syntax = 'Markdown';
          break;
        case 'textile':
          SassMeister.inputs.html.syntax = 'Textile';
          break;
        case 'html':
        default:
          SassMeister.inputs.html.syntax = 'HTML';
          break;
      }
      
      console.log(SassMeister.inputs.sass.syntax);
      //   SassMeister.inputs.sass.setValue(SassMeister.storedInputs.sass);
      //   SassMeister.inputs.sass.clearSelection();
      // 
      //   SassMeister.inputs.html.setValue(SassMeister.storedInputs.html);
      //   SassMeister.inputs.html.clearSelection();
      // 
      // 
      // SassMeister.orientation = localStorage.getItem('orientation') || SassMeister.orientation;
      // SassMeister.html = localStorage.getItem('html') || SassMeister.html;
      // SassMeister.css = localStorage.getItem('css') || SassMeister.css;
    },
    
    setStorage: function() {
      if(! window.gist) {
        localStorage.setItem('inputs', JSON.stringify( this.inputs ));
        localStorage.setItem('outputs', JSON.stringify( this.outputs ));
        localStorage.setItem('layout', JSON.stringify( this.layout ));
      }
    }
  };

})(jQuery);
