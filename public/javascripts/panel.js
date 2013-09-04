var $document = $(document),
    $window = $(window),
    $source = $('#source');

var Panel = function (name, settings) {
  var panel = this,
      $panel = null,
      splitterSettings = {},
      panelLanguage = name;

  panel.settings = settings = settings || {};
  panel.id = panel.name = name;
  $panel = $('.panel.' + name);
  $panel.data('name', name);
  panel.$el = $panel.detach();
  panel.$el.appendTo($source);
  panel.$el.wrapAll('<div class="stretch panelwrapper">');
  panel.$panel = panel.$el;
  panel.$el = panel.$el.parent().hide();
  panel.el = document.getElementById(name);
  panel.order = ++Panel.order;

  panel.$el.data('panel', panel);

  this._eventHandlers = {};

  panel.processor = function (str) { return str; };

  if (!settings.nosplitter) {
    panel.splitter = panel.$el.splitter(splitterSettings).data('splitter');
    panel.splitter.hide();
  } else {
    // create a fake splitter to let the rest of the code work
    panel.splitter = $();
  }
};

Panel.order = 0;

Panel.prototype = {
  virgin: true,
  visible: false,
  show: function (x) {
    // check to see if there's a panel to the left.
    // if there is, take it's size/2 and make this our
    // width
    var panel = this,
        panelCount = panel.$el.find('.panel').length;

    if (panel.splitter.length) {
      if (panelCount === 0 || panelCount > 1) {
        var $panel = $('.panel.' + panel.id).show();
        $panel.closest('.panelwrapper').show();
      } else {
        panel.$el.show();
      }
      panel.splitter.show();
    } else {
      panel.$el.show();
    }

    if (panel.settings.show) {
      panel.settings.show.call(panel, true);
    }
    // panel.controlButton.addClass('active');
    panel.visible = true;

    // update the splitter - but do it on the next tick
    // required to allow the splitter to see it's visible first
    setTimeout(function () {
      if (x !== undefined) {
        panel.splitter.trigger('init', x);
      } else {
        panel.distribute();
      }

      $document.trigger('sizeeditors');

      panel.trigger('show');

      panel.virgin = false;
    }, 0);
  },
  hide: function () {
    var panel = this;

    panel.visible = false;

    // update all splitter positions
    // LOGIC: when you go to hide, you need to check if there's
    // other panels inside the panel wrapper - if there are
    // hide the nested panel and any previous visible splitter
    // if there's only one - then hide the whole thing.

    var panelCount = panel.$el.find('.panel').length;
    if (panelCount === 0 || panelCount > 1) {
      var $panel = $('.panel.' + panel.id).hide();
      $panel.prev().hide(); // hide the splitter if there is one
      // TODO trigger a distribute horizontally
      if ($panel.closest('.panelwrapper').find('.panel:visible').length === 0) {
        $panel.closest('.panelwrapper').hide();
      }
    } else {
      panel.$el.hide();
      panel.splitter.hide();
    }

    panel.controlButton.removeClass('active');
    panel.distribute();

    if (panel.settings.hide) {
      panel.settings.hide.call(panel, true);
    }

    $document.trigger('sizeeditors');
    panel.trigger('hide');
  },
  toggle: function () {
    (this)[this.visible ? 'hide' : 'show']();
  },
  init: function () {
    if (this.settings.init) this.settings.init.call(this);
  },
  distribute: function () {
    var visible = $('#source .panelwrapper:visible'),
        width = 100,
        height = 0,
        innerW = $window.width() - (visible.length - 1), // to compensate for border-left
        innerH = $('#source').outerHeight(),
        left = 0,
        right = 0,
        top = 0,
        panel,
        nestedPanels = [];

    if (visible.length) {
      width = 100 / visible.length;
      for (var i = 0; i < visible.length; i++) {
        panel = $.data(visible[i], 'panel');
        right = 100 - (width * (i+1));
        panel.$el.css({ top: 0, bottom: 0, left: left + '%', right: right + '%' });
        panel.splitter.trigger('init', innerW * left/100);
        left += width;

        nestedPanels = $(visible[i]).find('.panel');
        if (nestedPanels.length > 1) {
          top = 0;
          nestedPanels = nestedPanels.filter(':visible');
          height = 100 / nestedPanels.length;
          nestedPanels.each(function (i) {
            bottom = 100 - (height * (i+1));
            $(this).css('top', top + '%');
            $(this).css('bottom', bottom + '%' );
            if (panel.splitter.hasClass('vertical')) {
              panel.splitter.trigger('init', innerH * top/100);
            }
            top += height;
          });
        }
      }
    }
  },
  // events
  on: function (event, fn) {
    (this._eventHandlers[event] = this._eventHandlers[event] || []).push(fn);
    return this;
  },
  trigger: function (event) {
    var args = [].slice.call(arguments, 1);
    args.unshift({ type: event });
    for (var list = this._eventHandlers[event], i = 0; list && list[i];) {
      list[i++].apply(this, args);
    }
    return this;
  }
};

$(window).on('resize', function(event) {
  $document.trigger('sizeeditors');
});

$document.bind('sizeeditors', function () {
  SassMeister.inputs.sass.resize();
  SassMeister.outputs.css.resize();

  SassMeister.inputs.html.resize();
});