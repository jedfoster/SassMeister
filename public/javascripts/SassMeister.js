;(function($) {

  var sassmeister = 'SassMeister';

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
  };

  $.fn[sassmeister] = function() {
    return SassMeister.init();
  }
})(jQuery);

