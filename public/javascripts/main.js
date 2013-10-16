(function($) {
if($('body.about, body.thankyou').length < 1 ) {

  $('#rendered-html').attr('src', window.sandbox);

  var SassMeister = window.SassMeister.init();




  $('.orientation').on('click', function(event) {
    $('#source').casement('destroy');
    $('#casement').casement('destroy');

    SassMeister.arrangePanels( $(this).data('orientation') );
  });


  if (gist) {
    if (gist.can_update_gist) {
      $('#save-gist').data('action', 'edit').attr('class', 'edit-gist').find('span').text('Update Gist');
    }
    else {
      $('#save-gist').data('action', 'fork').attr('class', 'fork-gist').find('span').text('Fork Gist');
    }
  }
  else {
    $('#save-gist').data('action', 'create').attr('class', 'create-gist').find('span').text('Save Gist');
  }


  $('.panel-toggle li span').on('click', function(event) {
    event.preventDefault();

    var selected = $(this).data('toggle-value'),
        input = $(this).data('toggle-input');

    $(this).parents('.panel-toggle').find('.selected').text(selected);

    if (input == 'sass') {
      SassMeister.inputs.sass.syntax = selected;

      SassMeister.convert.sass();
      SassMeister.editors.sass.getSession().setMode('ace/mode/' + selected.toLowerCase());
    }
    if (input == 'css') {
      SassMeister.inputs.sass.output_style = selected;

      SassMeister.compile.sass();
    }
    if (input == 'html') {
      SassMeister.inputs.html.syntax = selected;

      SassMeister.compile.html();
      SassMeister.editors.html.getSession().setMode("ace/mode/" + selected.toLowerCase());
    }
  });





  $('[data-import]').on('click', function(event) {
    var imports = $(this).data('import').split(','),
        eol = ( SassMeister.inputs.sass.syntax == 'SCSS' ? ';' : '' ) + '\n';

    $(imports).each(function() {      
      SassMeister.editors.sass.insert( '@import "' + this + '"' + eol);
    });    
  });


  var toggleCSSPanel = function(state) {
    $('#source').casement('destroy');
    $('#casement').casement('destroy');

    $('#css_input')[state]();

    $('#rendered')[SassMeister.layout.html]();
    $('#html_input')[SassMeister.layout.html]();

    SassMeister.layout.css = state;

    SassMeister.arrangePanels(SassMeister.layout.orientation);

    SassMeister.editors.sass.resize();
    SassMeister.editors.css.resize();

    localStorage.setItem('layout', JSON.stringify( SassMeister.layout ));
  };


  var toggleHTMLPanels = function(state) {
    $('#source').casement('destroy');
    $('#casement').casement('destroy');

    $('#rendered')[state]();
    $('#html_input')[state]();

    $('#css_input')[SassMeister.layout.css]();

    SassMeister.layout.html = state;

    SassMeister.arrangePanels(SassMeister.layout.orientation);

    SassMeister.editors.sass.resize();
    SassMeister.editors.css.resize();
    SassMeister.editors.html.resize();

    localStorage.setItem('layout', JSON.stringify( SassMeister.layout ));
  };











  $("a[href^='http://'], a[href^='https://']").attr("target", "_blank");

  $('#save-gist').on('click', function(event) {
    event.preventDefault();

    SassMeister.gist[($(this).data('action'))]();
  });

  $('#reset').on('click', function(event) {
    event.preventDefault();

    SassMeister.reset();
  });

  $('#toggle_css').on('click', function(event) {
    event.preventDefault();

    var state = $(this).data("state")

    toggleCSSPanel(state);

    if(state == 'hide') {
      $(this).data("state", 'show').toggleClass('show').find('span');
    }
    else {
      $(this).data("state", 'hide').toggleClass('show').find('span');
    }
  });

  $('#toggle_html').on('click', function(event) {
    event.preventDefault();

    var state = $(this).data("state")

    toggleHTMLPanels(state);

    if(state == 'hide') {
      $(this).data("state", 'show').toggleClass('show').find('span');
    }
    else {
      $(this).data("state", 'hide').toggleClass('show').find('span');
    }
  });







  window.onmessage = function (event) {
    if (SassMeister.layout.html == 'show') {
      if(SassMeister.outputs.html) {
        SassMeister.updateRender(SassMeister.outputs);
      }
      else {
        SassMeister.compile.html();
      }
    }
  };
  
}

})(jQuery);
