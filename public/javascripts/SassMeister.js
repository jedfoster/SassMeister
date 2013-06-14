;(function($) {

  var sassmeister = 'SassMeister';

  // function SassMeister(  ) {
  //   this.bar = 'zzz';
  //
  //   this._name = sassmeister;
  //
  //   this.inputs = {
  //     sass: 'foo',
  //     html: 'bar'
  //   };
  //
  //   this.init();
  // }

  SassMeister = {
    init: function() {
      var $this = this;

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

    
  };

  $.fn[sassmeister] = function() {
    return SassMeister.init();
  }
})(jQuery);

