var SassMeister;

(function($) {

  window.SassMeister = {
    init: function() {
      this.inputs.sass = ace.edit("sass");
      this.inputs.sass.setTheme("ace/theme/tomorrow");
      this.inputs.sass.getSession().setMode("ace/mode/scss");
      this.inputs.sass.focus();

      this.inputs.html = ace.edit("html");
      this.inputs.html.setTheme("ace/theme/tomorrow");
      this.inputs.html.getSession().setMode("ace/mode/html");

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

      this.retreiveStorage();

      return this;
    },
    
    inputs: {
      sass: '',
      html: ''
    },

    outputs: {
      css: '',
      html: ''
    },

    timers: {
      sass: '',
      html: ''
    },
    
    compile: {
      sass: function() {        
        var inputs = {
              sass: SassMeister.inputs.sass.getValue(),
              syntax: $('select[name="syntax"]').val(),
              plugin: $('select[name="plugin"]').val(),
              output: $('select[name="output"]').val()
            };

        _gaq.push(['_trackEvent', 'Form', 'Submit']);

        /* Post the form and handle the returned data */
        $.post('/compile', inputs,
          function( data ) {
            SassMeister.outputs.css.setValue(data,-1);

            $('select[name="syntax"]').data('orignal', inputs.syntax);
          }
        );

        localStorage.setItem('inputs', JSON.stringify(inputs));
      },

      html: function() {
        var inputs = {
              html: SassMeister.inputs.html.getValue(),
              syntax: $('select[name="html-syntax"]').val()
            };

        _gaq.push(['_trackEvent', 'Form', 'Submit']);

        /* Post the form and handle the returned data */
        $.post('/compile', inputs,
          function( data ) {
            //console.log(data)
          }
        );

        localStorage.setItem('inputs', JSON.stringify(inputs));
      },
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
  
    retreiveStorage: function() {
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
        // $("#sass-form").submit();
        this.compile.sass();
      }
    },
  };

  // $.fn[sassmeister] = function() {
  //   return SassMeister.init();
  // }
  
  // $.fn[sassmeister] = function() {
  //   return this.each(function () {
  //     if (!$.data(this, 'plugin_' + sassmeister)) {
  //       $.data(this, 'plugin_' + sassmeister, new SassMeister( this ));
  //     }
  //   });
  // }
  
})(jQuery);

