var SassMeister;

(function($) {

  window.SassMeister = {
    // init: function() {
      // this.inputs.sass = ace.edit("sass");
      // this.inputs.sass.setTheme("ace/theme/tomorrow");
      // this.inputs.sass.getSession().setMode("ace/mode/scss");
      // this.inputs.sass.focus();
      //
      // this.inputs.html = ace.edit("html");
      // this.inputs.html.setTheme("ace/theme/tomorrow");
      // this.inputs.html.getSession().setMode("ace/mode/html");

      // this.getStorage();

      // if (this.html == 'hide') {
      //   $('#rendered').hide();
      //   $('#html_input').hide();
      //   $('#toggle_html').data("state", 'show').toggleClass('show');
      // }
      //
      // if (this.css == 'hide') {
      //   $('#css_input').hide();
      //   $('#toggle_css').data("state", 'show').toggleClass('show');
      // }

      // this.arrangePanels(SassMeister.orientation);

      // if (this.storedInputs == null || !this.storedInputs.syntax) {
      //   $('#syntax').text('SCSS').data('original', 'SCSS');
      //   this.inputs.syntax = 'SCSS';
      // }
      // else {
      //   $('#syntax').text(this.storedInputs.syntax).data('original', this.storedInputs.syntax);
      //   this.inputs.syntax = this.storedInputs.syntax;
      // }
      //
      // if (this.storedInputs == null || !this.storedInputs.output) {
      //   $('#output').text('expanded');
      //   this.inputs.output = 'expanded';
      // }
      // else {
      //   $('#output').text(this.storedInputs.output);
      //   this.inputs.output = this.storedInputs.output;
      // }
      //
      // if (this.storedInputs == null || !this.storedInputs.html_syntax) {
      //   $('#html-syntax').text('HTML');
      //   this.inputs.html_syntax = 'HTML';
      // }
      // else {
      //   $('#html-syntax').text(this.storedInputs.html_syntax);
      //   this.inputs.html_syntax = this.storedInputs.html_syntax;
      // }

      // this.outputs.css = ace.edit("css");
      // this.outputs.css.setTheme("ace/theme/tomorrow");
      // this.outputs.css.setReadOnly(true);
      // this.outputs.css.getSession().$useWorker=false
      // this.outputs.css.getSession().setMode("ace/mode/css");


      // if(this.storedOutputs.css) {
      //   this.outputs.css.setValue(this.storedOutputs.css);
      //   this.outputs.css.clearSelection();
      // }
      // else {
      //   this.compile.sass();
      // }

      // $(this.inputs.sass.getSession()).bindWithDelay('change', function(event) {
      //   if(SassMeister.internalValueChange == true) {
      //     SassMeister.internalValueChange = false;
      //   }
      //   else {
      //     SassMeister.compile.sass();
      //   }
      // }, 750);

      // $(this.inputs.html.getSession()).bindWithDelay('change', function(event) {
      //   SassMeister.convert.html();
      // }, 750);


      // return this;
    // },

    // inputs: {
    //   sass: '',
    //   syntax: 'SCSS',
    //   plugin: '',
    //   output: 'expanded',
    //   html: '',
    //   html_syntax: 'HTML'
    // },
    //
    // outputs: {
    //   css: '',
    //   html: ''
    // },

    // timer: null,
    //
    // orientation: 'horizontal',
    //
    // html: 'show',
    //
    // css: 'show',

    // compile: {
    //   sass: function() {
    //     var inputs = {
    //           sass: SassMeister.inputs.sass.getValue(),
    //           syntax: SassMeister.inputs.syntax,
    //           output: SassMeister.inputs.output,
    //         };
    //
    //     // _gaq.push(['_trackEvent', 'Form', 'Submit']);
    //
    //     /* Post the form and handle the returned data */
    //     $.post('/compile', inputs, function( data ) {
    //       SassMeister.outputs.css.setValue(data,-1);
    //
    //       $('#syntax').data('original', inputs.syntax);
    //
    //       SassMeister.updateRender({
    //         css: data
    //       });
    //
    //       SassMeister.setStorage(inputs, {css: data});
    //     });
    //   }
    // },

    // internalValueChange: false,

    // convert: {
    //   sass: function(convert_syntax) {
    //     if(convert_syntax == true) {
    //       var inputs = {
    //         sass: SassMeister.inputs.sass.getValue(),
    //         syntax: SassMeister.inputs.syntax,
    //         original_syntax: $('#syntax').data('original'),
    //         output: SassMeister.inputs.output
    //       }
    //
    //       $.post('/convert', inputs, function( data ) {
    //         SassMeister.internalValueChange = true;
    //
    //         SassMeister.inputs.sass.setValue(data, -1);
    //
    //         $('#syntax').data('original', inputs.syntax);
    //
    //         SassMeister.setStorage({
    //           sass: data,
    //           syntax: SassMeister.inputs.syntax,
    //           output: SassMeister.inputs.output
    //         }, { });
    //       });
    //     }
    //     else {
    //       SassMeister.compile.sass();
    //     }
    //   }
    // },

    // updateRender: function(new_content) {
    //   $('#rendered-html')[0].contentWindow.postMessage(JSON.stringify(new_content), '*');
    // },

    // arrangePanels: function(orientation) {
    //   if (this.html == 'hide') {
    //     $('#rendered').hide();
    //     $('#html_input').hide();
    //   }
    //
    //   // #source has to be done FIRST, since it is nested inside #casement. TODO: Fix this.
    //   $('#source').casement({
    //     split: (orientation == 'horizontal' ? 'vertical' : 'horizontal'),
    //     onDrag: function() {
    //       SassMeister.inputs.sass.resize();
    //       SassMeister.outputs.css.resize();
    //       SassMeister.inputs.html.resize();
    //     }
    //   });
    //
    //   $('#casement').casement({
    //     split: orientation,
    //     onDragStart: function() {
    //       $('#sash_cover').show();
    //     },
    //     onDrag: function() {
    //       SassMeister.inputs.sass.resize();
    //       SassMeister.outputs.css.resize();
    //       SassMeister.inputs.html.resize();
    //     },
    //     onDragEnd: function() {
    //       $('#sash_cover').hide();
    //     }
    //   });
    //
    //   this.orientation = orientation;
    //   localStorage.setItem('orientation', this.orientation);
    // },



    gist: {
      create: function() {
        _gaq.push(['_trackEvent', 'Gist']);

        var inputs = {
          sass: {
            input: SassMeister.inputs.sass.getValue(),
            syntax: SassMeister.inputs.syntax,
            output: SassMeister.outputs.css.getValue(),
          },
          html: {
            input: SassMeister.inputs.html.getValue(),
            syntax: SassMeister.inputs.html_syntax,
            output: JSON.parse(localStorage.getItem('outputs')).html
          }
        }

        var confirmationText = 'is ready';

        ///* Send the data using post and put the results in a div */
        $.post('/gist/create', inputs, function( data ) {
          window.modal('<a href="https://gist.github.com/' + data.id + '" target="_blank">Your Gist</a> ' + confirmationText + ', and here\'s the <a href="/gist/' + data.id + '">SassMeister live view.</a> ');

          window.setUrl('/gist/' + data.id);
          SassMeister.storedInputs.gist_id = data.id;
          SassMeister.storedInputs.sass_filename = data.sass_filename;
          SassMeister.storedInputs.html_filename = data.html_filename;

          $('#save-gist').text('Update Gist').data('action', 'edit');
        });
      },

      edit: function() {
        _gaq.push(['_trackEvent', 'Gist']);

        var inputs = {
          sass: {
            input: SassMeister.inputs.sass.getValue(),
            syntax: SassMeister.inputs.syntax,
            output: SassMeister.outputs.css.getValue(),
            filename: SassMeister.storedInputs.sass_filename
          },
          html: {
            input: SassMeister.inputs.html.getValue(),
            syntax: SassMeister.inputs.html_syntax,
            output: JSON.parse(localStorage.getItem('outputs')).html,
            filename: SassMeister.storedInputs.html_filename
          }
        }

        var confirmationText = 'has been updated';

        ///* Send the data using post and put the results in a div */
        $.post('/gist/' + SassMeister.storedInputs.gist_id + '/edit', inputs, function( data ) {
          window.modal('<a href="https://gist.github.com/' + data.id + '" target="_blank">Your Gist</a> ' + confirmationText + ', and here\'s the <a href="/gist/' + data.id + '">SassMeister live view.</a> ');

          window.setUrl('/gist/' + data.id);
          SassMeister.storedInputs.sass_filename = data.sass_filename;
          SassMeister.storedInputs.html_filename = data.html_filename;

        });
      },

      fork: function() {
        _gaq.push(['_trackEvent', 'Gist']);

        var confirmationText = 'has been forked';

        ///* Send the data using post and put the results in a div */
        $.post('/gist/' + SassMeister.storedInputs.gist_id + '/fork', function( data ) {
          window.modal('<a href="https://gist.github.com/' + data.id + '" target="_blank">This Gist</a> ' + confirmationText + ', and here\'s the <a href="/gist/' + data.id + '">SassMeister live view.</a> ');

          window.setUrl('/gist/' + data.id);
          SassMeister.storedInputs.gist_id = data.id;

          $('#save-gist').text('Update Gist').data('action', 'edit').attr('class', 'edit-gist');
        });
      },
    },

    // reset: function() {
    //   $('#save-gist').text('Save Gist').data('action', 'create');
    //
    //   SassMeister.inputs.sass.setValue('');
    //   SassMeister.outputs.css.setValue('');
    //   SassMeister.inputs.html_syntax = $('#html-syntax').text('HTML');
    //   SassMeister.inputs.html.setValue('');
    //
    //   localStorage.clear();
    //   SassMeister.storedInputs = {};
    //   SassMeister.storedOutputs = {};
    //
    //   SassMeister.updateRender({reset: true});
    //
    //   window.setUrl('/');
    // },



    // storedInputs: null,
    // storedOutputs: null,
    //
    // getStorage: function() {
    //   if(gist) {
    //     SassMeister.storedInputs = gist;
    //     SassMeister.storedOutputs = {css: null, html: null};
    //   }
    //   else {
    //     SassMeister.storedInputs = JSON.parse(localStorage.getItem('inputs'));
    //     SassMeister.storedOutputs = $.extend({css: '', html: ''}, JSON.parse(localStorage.getItem('outputs')));
    //   }
    //
    //   if(SassMeister.storedInputs) {
    //     switch (SassMeister.storedInputs.syntax) {
    //       case 'scss':
    //         SassMeister.storedInputs.syntax = 'SCSS';
    //         break;
    //       case 'sass':
    //         SassMeister.storedInputs.syntax = 'Sass';
    //         break;
    //       default:
    //         break;
    //     }
    //
    //     switch (SassMeister.storedInputs.html_syntax) {
    //       case 'html':
    //         SassMeister.storedInputs.html_syntax = 'HTML';
    //         break;
    //       case 'haml':
    //         SassMeister.storedInputs.html_syntax = 'Haml';
    //         break;
    //       case 'slim':
    //         SassMeister.storedInputs.html_syntax = 'Slim';
    //         break;
    //       case 'markdown':
    //         SassMeister.storedInputs.html_syntax = 'Markdown';
    //         break;
    //       case 'textile':
    //         SassMeister.storedInputs.html_syntax = 'Textile';
    //         break;
    //       default:
    //         break;
    //     }
    //
    //     SassMeister.inputs.sass.setValue(SassMeister.storedInputs.sass);
    //     SassMeister.inputs.sass.clearSelection();
    //
    //     SassMeister.inputs.html.setValue(SassMeister.storedInputs.html);
    //     SassMeister.inputs.html.clearSelection();
    //   }
    //
    //   SassMeister.orientation = localStorage.getItem('orientation') || SassMeister.orientation;
    //   SassMeister.html = localStorage.getItem('html') || SassMeister.html;
    //   SassMeister.css = localStorage.getItem('css') || SassMeister.css;
    // },

    // setStorage: function(inputs, outputs) {
    //   localStorage.setItem('inputs', JSON.stringify( $.extend(SassMeister.storedInputs, inputs) ));
    //   localStorage.setItem('outputs', JSON.stringify( $.extend(SassMeister.storedOutputs, outputs) ));
    //
    //   localStorage.setItem('orientation', SassMeister.orientation);
    //   localStorage.setItem('html', SassMeister.html);
    // }
  };

})(jQuery);

