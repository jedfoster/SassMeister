(function($) {
if($('body.app, body.embedded').length > 0 ) {
  var SassMeister = window.SassMeister.init();

  $('#rendered-html').attr('src', window.sandbox);

  $("a[href^='http://'], a[href^='https://']").attr('target', '_blank');

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

  if($('body.app').length > 0 ) {
    SassMeister.editors.sass.focus();
  }
}


if($('body.app').length > 0 ) {
  window.github_id = $.cookie('github_id');
  window.avatar_url = $.cookie('avatar_url');

  if(window.github_id && window.avatar_url) {
    $('#github-auth').replaceWith('<div><span><img src="' + window.avatar_url + '" alt="" height="40"></span>\
      <ul id="account_actions">\
        <li class="checkmark-icon">Logged in as ' + window.github_id + '</li>\
        <li class="off-icon"><a href="/logout"><span>Logout</span></a></li>\
      </ul>\
    </div>');
  }


  var buildCloudMenu = function() {
    var menu = '';

    if(window.github_id) {
      if((window.gist && (window.gist.owner == window.github_id))) {
        menu += '<li><a id="save-gist" data-action="edit" class="edit-gist"><span>Update Gist</span></a></li>';
      }
      else if(! window.gist) {
        menu += '<li><a id="save-gist" data-action="create" class="create-gist"><span>Save Gist</span></a></li>';
      }
    }
    if((window.github_id && window.gist)) {
      menu += '<li><a id="fork-gist" data-action="create" class="fork-gist"><span>Fork Gist</span></a></li>';
    }
    if(! window.github_id) {
      menu += '<li><a href="/authorize" class="github"><span>Log in with your GitHub account to save gists</span></a></li>';
    }
    if(window.gist) {
      menu += '<li><a href="https://gist.github.com/' + window.gist.gist_id + '" class="github" id="gist-link"><span>View on GitHub</span></a></li>';
    }

    $('#menu-placeholder').replaceWith(menu);
  };

  buildCloudMenu();


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
    $('select[name="version"] option[value="' + SassMeister.inputs.sass.compiler + '"]').prop('selected', true);
    $('input[name="syntax"][value="' + SassMeister.inputs.sass.syntax.toLowerCase() + '"]').prop('checked', true);
    $('input[name="output-style"][value="' + SassMeister.inputs.sass.output_style + '"]').prop('checked', true);
    $('input[name="html-syntax"][value="' + SassMeister.inputs.html.syntax + '"]').prop('checked', true);
    $('select[name="theme"] option[value="' + SassMeister.preferences.theme + '"]').prop('selected', true);
    $('input[name="emmet"]').prop('checked', SassMeister.preferences.emmet);
    $('input[name="vim"]').prop('checked', SassMeister.preferences.vim);
    $('input[name="scrollPastEnd"]').prop('checked', SassMeister.preferences.scrollPastEnd);

    $('select[name="theme"]').dropdown({
      gutter : 0,
      speed : 25,
      onOptionSelect: function(opt) {
        SassMeister.setTheme(opt.data('value'));
      }
    });

    $('select[name="version"]').dropdown({
      gutter : 0,
      speed : 25,
      onOptionSelect: function(opt) {
        _gaq.push(['_trackEvent', 'UI', 'SassVersion', 'v ' + opt.data('value')]);

        SassMeister.inputs.sass.compiler = opt.data('value');

        getExtensions();
        SassMeister.compile.sass();
      }
    });

    ace.require("ace/ext/emmet");

    $('.edit-prefs input[type="checkbox"]').on('change', function(event) {
      SassMeister.setEditorPreferences($(this).attr('name'), $(this).prop('checked'));
    });
  };

  initControls();


  $('.orientation').on('click', function(event) {
    var orientation = $(this).data('orientation');

    _gaq.push(['_trackEvent', 'UI', 'Orientation', orientation]);

    $('#source').casement('destroy');
    $('#casement').casement('destroy');

    SassMeister.arrangePanels(orientation);
  });


  $('[data-toggle-input]').on('click', function(event) {
    var selected = $('#' + $(this).attr('for')).val(),
        input = $(this).data('toggle-input');

    if (input == 'sass') {
      _gaq.push(['_trackEvent', 'UI', 'SassSyntax', selected]);

      SassMeister.inputs.sass.syntax = selected;
      $('.sass-syntax-display').text($(this).text());

      SassMeister.convert.sass();
      SassMeister.editors.sass.getSession().setMode('ace/mode/' + selected.toLowerCase());
    }
    if (input == 'css') {
      _gaq.push(['_trackEvent', 'UI', 'CSSOutput', selected]);

      SassMeister.inputs.sass.output_style = selected;

      SassMeister.compile.sass();
    }
    if (input == 'html') {
      _gaq.push(['_trackEvent', 'UI', 'HTMLSyntax', selected]);

      SassMeister.inputs.html.syntax = selected;
      $('.html-syntax-display').text($(this).text());

      SassMeister.compile.html();
      SassMeister.editors.html.getSession().setMode("ace/mode/" + selected.toLowerCase());
    }
  });


  var buildExtensionList = function(data) {
    var list = $('<ol />');

    $.each(data, function(name, info) {
      list.append('<li><a data-import="' + info.import + '">' + name + '</a>' + (info.version ? '&nbsp;&nbsp;(v' + info.version + ')' : '' ) + '</li>');
    });

    return list;
  };


  var getExtensions = function() {
    var html = $('input[value=\'' + SassMeister.inputs.sass.compiler + '\']').data('extensions');

    if(html) {
      $('#extension_list ol').replaceWith(buildExtensionList(html));
      return;
    }

    if(SassMeister.ajaxCalls.getExtensions) {
      SassMeister.ajaxCalls.getExtensions.abort();
    }

    SassMeister.ajaxCalls.getExtensions = $.get('/app/' + SassMeister.inputs.sass.compiler + '/extensions')
      .done(function( data ) {
        $('#extension_list ol').replaceWith(buildExtensionList(data));
        $('input[value=\'' + SassMeister.inputs.sass.compiler + '\']').data('extensions', data);
      })
      .always(function() {
        SassMeister.ajaxCalls.getExtensions = false;
      });
  };

  getExtensions();


  $('#control-column').on('click', 'a[data-import]', function(event) {
    var imports = $(this).data('import'),
        eol = ( SassMeister.inputs.sass.syntax == 'SCSS' ? ';' : '' ) + '\n';

    _gaq.push(['_trackEvent', 'UI', 'SassExtensions', imports]);

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


  var toggleCSSPanel = function(state) {
    _gaq.push(['_trackEvent', 'UI', 'ToggleCSS', state]);

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
    _gaq.push(['_trackEvent', 'UI', 'ToggleHTML', state]);

    $('#source').casement('destroy');
    $('#casement').casement('destroy');

    $('#rendered')[state]();
    $('[data-name="html"]')[state]();

    $('[data-name="css"]')[SassMeister.layout.css]();

    SassMeister.layout.html = state;

    SassMeister.arrangePanels(SassMeister.layout.orientation);

    localStorage.setItem('layout', JSON.stringify( SassMeister.layout ));
  };


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

    var state = $(this).data('state');

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

    var state = $(this).data('state')

    toggleHTMLPanels(state);

    if(state == 'hide') {
      $(this).data("state", 'show').addClass('show');
    }
    else {
      $(this).data("state", 'hide').removeClass('show').find('span');
    }
  });
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
