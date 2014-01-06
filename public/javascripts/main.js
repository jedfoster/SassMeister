(function($) {
if($('body.about, body.thankyou').length < 1 ) {

  $('#rendered-html').attr('src', window.sandbox);

  var SassMeister = window.SassMeister.init();


  if(window.github_id) {
    $('#github-auth').replaceWith('<div class="github"><span><img src="http://www.gravatar.com/avatar/' + window.gravatar_id + '?s=80" alt="" height="40"></span>\
      <ul id="account_actions">\
        <li class="checkmark-icon">Logged in as ' + window.github_id + '</li>\
        <li class="off-icon"><a href="/logout"><span>Logout</span></a></li>\
      </ul>\
    </div>');
  }


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
    $('#sass-syntax-display').text(SassMeister.inputs.sass.syntax);
    $('#html-syntax-display').text(SassMeister.inputs.html.syntax);

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


  if (window.github_id) {
    if (window.gist) {
      if (window.gist.can_update_gist == true) {
        $('#save-gist').data('action', 'edit').attr('class', 'edit-gist').find('span').text('Update Gist');
      }
      else {
        $('#save-gist').data('action', 'fork').attr('class', 'fork-gist').find('span').text('Fork Gist');
      }
    }
    else {
      $('#save-gist').data('action', 'create').attr('class', 'create-gist').find('span').text('Save Gist');
    }
  }
  else {
    $('#save-gist').attr('href', '/authorize').attr('class', 'github-login').find('span').text('Log in with your GitHub account to save gists');
  }


  if (window.gist) {
    $('#cloud_actions li:first-child').after('<li><a href="https://gist.github.com/' + window.gist.gist_id + '" target="_blank" class="jump-icon" id="gist-link">View on GitHub</a></li>');
  }


  $('[data-toggle-input]').on('click', function(event) {
    var selected = $('#' + $(this).attr('for')).val(),
        input = $(this).data('toggle-input');

    if (input == 'version') {
      _gaq.push(['_trackEvent', 'UI', 'SassVersion']);

      SassMeister.sass_version = selected;

      if (selected == 'lib') {
        $('#syntax-scss').prop('checked', true);
        
        $('.syntax-toggle-group').addClass('libsass');
      }
      else {
        $('.syntax-toggle-group').removeClass('libsass');
      }

      getExtensions();
    }
    if (input == 'sass') {
      _gaq.push(['_trackEvent', 'UI', 'SassSyntax']);

      SassMeister.inputs.sass.syntax = selected;
      $('#sass-syntax-display').text($(this).text());

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
      $('#html-syntax-display').text($(this).text());

      SassMeister.compile.html();
      SassMeister.editors.html.getSession().setMode("ace/mode/" + selected.toLowerCase());
    }
  });


  var getExtensions = function() {
    $.get(SassMeister.sass_endpoint() + 'extensions', function( data ) {
      $('#extension_list').replaceWith(data);
      watchExtensions();
      SassMeister.compile.sass();

      if(SassMeister.sass_version == 'lib') {
        $('#sass-syntax-toggle').addClass('disabled');
      }
      else {
        $('#sass-syntax-toggle').removeClass('disabled');
      }
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

    SassMeister.editors.sass.resize();
    SassMeister.editors.css.resize();

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
