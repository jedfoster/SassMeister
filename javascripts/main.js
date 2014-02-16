(function($) {
if($('body.app, body.embedded').length > 0 ) {

  $('#rendered-html').attr('src', window.sandbox);

  var SassMeister = window.SassMeister.init();

  $('#control-column-bg').on('click', function(event) {
    $('#control-column, #control-column-bg').removeClass('open');
  });

  $("#control-column").on('click', function(event) {
    event.stopPropagation();
  });

  $('.control-icon').on('click', function(event) {
    event.stopPropagation();
    $('#control-column, #control-column-bg').toggleClass('open');
  });


  var initControls = function() {
    $('.sass-syntax-display').text(SassMeister.inputs.sass.syntax);
    $('.html-syntax-display').text(SassMeister.inputs.html.syntax);

    $('input[name="version"][value="' + SassMeister.sass_version + '"]').prop('checked', true);

    $('input[name="syntax"][value="' + SassMeister.inputs.sass.syntax.toLowerCase() + '"]').prop('checked', true);

    $('input[name="output-style"][value="' + SassMeister.inputs.sass.output_style + '"]').prop('checked', true);

    $('input[name="html-syntax"][value="' + SassMeister.inputs.html.syntax + '"]').prop('checked', true);
  };

  initControls();


  $('.orientation').on('click', function(event) {
    _gaq.push(['_trackEvent', 'UI', 'Orientation']);

    $('#source').casement('destroy');
    $('#casement').casement('destroy');

    SassMeister.arrangePanels( $(this).data('orientation') );
  });


  $('[data-toggle-input]').on('click', function(event) {
    var selected = $('#' + $(this).attr('for')).val(),
        input = $(this).data('toggle-input');

    if (input == 'version') {
      _gaq.push(['_trackEvent', 'UI', 'SassVersion']);

      SassMeister.sass_version = selected;

      if (selected == 'lib') {
        $('#syntax-scss').prop('checked', true);

        $('#control-column').addClass('libsass');
      }
      else {
        $('#control-column').removeClass('libsass');
      }

      getExtensions();
      SassMeister.compile.sass();
    }
    if (input == 'sass') {
      _gaq.push(['_trackEvent', 'UI', 'SassSyntax']);

      SassMeister.inputs.sass.syntax = selected;
      $('.sass-syntax-display').text($(this).text());

      SassMeister.convert.sass();
      SassMeister.editors.sass.getSession().setMode('ace/mode/' + selected.toLowerCase());
    }
    if (input == 'css') {
      _gaq.push(['_trackEvent', 'UI', 'CSSOutput']);

      SassMeister.inputs.sass.output_style = selected;

      SassMeister.compile.sass();
    }
    if (input == 'html') {
      _gaq.push(['_trackEvent', 'UI', 'HTMLSyntax']);

      SassMeister.inputs.html.syntax = selected;
      $('.html-syntax-display').text($(this).text());

      SassMeister.compile.html();
      SassMeister.editors.html.getSession().setMode("ace/mode/" + selected.toLowerCase());
    }
  });


  var getExtensions = function() {
    if(SassMeister.ajaxCalls.getExtensions) {
      SassMeister.ajaxCalls.getExtensions.abort();
    }

    SassMeister.ajaxCalls.getExtensions = $.get(SassMeister.sass_endpoint() + 'extensions')
      .done(function( data ) {
        $('#extension_list').replaceWith(data);
        watchExtensions();
      })
      .always(function() {
        SassMeister.ajaxCalls.getExtensions = false;
      });
  };


  var watchExtensions = function() {
    $('[data-import]').on('click', function(event) {
      _gaq.push(['_trackEvent', 'UI', 'SassExtensions']);

      var imports = $(this).data('import'),
          eol = ( SassMeister.inputs.sass.syntax == 'SCSS' ? ';' : '' ) + '\n';

      if(String(imports) === 'true') {
        imports = [imports];
      }
      else {
        imports = imports.split(',');
      }

      $(imports).each(function() {
        SassMeister.editors.sass.insert( '@import "' + this + '"' + eol);
      });
    });
  };


  getExtensions();


  var toggleCSSPanel = function(state) {
    _gaq.push(['_trackEvent', 'UI', 'ToggleCSS']);

    $('#source').casement('destroy');
    $('#casement').casement('destroy');

    $('[data-name="css"]')[state]();

    $('#rendered')[SassMeister.layout.html]();
    $('[data-name="html"]')[SassMeister.layout.html]();

    SassMeister.layout.css = state;

    SassMeister.arrangePanels(SassMeister.layout.orientation);

    localStorage.setItem('layout', JSON.stringify( SassMeister.layout ));
  };


  var toggleHTMLPanels = function(state) {
    _gaq.push(['_trackEvent', 'UI', 'ToggleHTML']);

    $('#source').casement('destroy');
    $('#casement').casement('destroy');

    $('#rendered')[state]();
    $('[data-name="html"]')[state]();

    $('[data-name="css"]')[SassMeister.layout.css]();

    SassMeister.layout.html = state;

    SassMeister.arrangePanels(SassMeister.layout.orientation);

    localStorage.setItem('layout', JSON.stringify( SassMeister.layout ));
  };


  $("a[href^='http://'], a[href^='https://']").attr("target", "_blank");


  $('#save-gist, #fork-gist').on('click', function(event) {
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
      $(this).data("state", 'show').addClass('show');
    }
    else {
      $(this).data("state", 'hide').removeClass('show');
    }
  });

  $('#toggle_html').on('click', function(event) {
    event.preventDefault();

    var state = $(this).data("state")

    toggleHTMLPanels(state);

    if(state == 'hide') {
      $(this).data("state", 'show').addClass('show');
    }
    else {
      $(this).data("state", 'hide').removeClass('show');
    }
  });


  $('#mobile-tabs h2').on('click', function(event) {
    if($('body').hasClass('single-column')) {
      $('.panel').removeClass('show-panel').addClass('hide-panel');
      $('#mobile-tabs .current').removeClass('current');
      $(this).toggleClass('current')

      $('[data-name="' + $(this).data('tab') + '"]').removeClass('hide-panel').addClass('show-panel');
    }

    else {
      $('.panel').removeClass('hide-panel').removeClass('show-panel');
    }

    SassMeister.resizeEditors();
  });


  window.onmessage = function (event) {
    if(event.origin == window.sandbox && SassMeister.layout.html == 'show') {
      if(SassMeister.outputs.html) {
        SassMeister.updateRender(SassMeister.outputs);
      }
      else {
        SassMeister.compile.html();
      }
    }
  };
}

if($('body.oops-404').length > 0 ) {
  var gotogist = function() {
    var id = document.getElementById('gist-id').value;

    if(id) {
      window.location = '/gist/' + id;
    }

    return true;
  };

  $('#gist-id').on('keydown', function(event) {
    if(event.which == 13) {
      gotogist();
    }
  });

  $('button').on('click', gotogist);
}
})(jQuery);
