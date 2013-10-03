(function($) {
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
        input = $(this).data('toggle-input').split('.');

    SassMeister.inputs[input[0]][input[1]] = selected;

    $(this).parents('.panel-toggle').find('.selected').text(selected);

    if (input[1] == 'syntax') {
      SassMeister.convert.sass(true);
      SassMeister.editors.sass.getSession().setMode('ace/mode/' + selected.toLowerCase());
    }
    if (input[1] == 'output') {
      SassMeister.compile.sass();
    }
    if (input[1] == 'html_syntax') {
      SassMeister.convert.html();
      SassMeister.inputs.html.getSession().setMode("ace/mode/" + selected.toLowerCase());
    }
  });

  $('[data-import]').on('click', function(event) {
    SassMeister.inputs.sass.insert( '@import "' + $(this).data('import') + '"' + ( SassMeister.inputs.syntax == 'scss' ? ';' : '' ) + '\n\n');
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

    localStorage.setItem('css', state);
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

    localStorage.setItem('html', state);
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
    if (SassMeister.html == 'show') {
      if(SassMeister.storedOutputs.html) {
        SassMeister.updateRender(SassMeister.storedOutputs);
      }
      else {
        SassMeister.convert.html();
      }
    }
  };

})(jQuery);
