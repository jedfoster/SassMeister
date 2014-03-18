(function($) {
  window.setViewportSize = function() {
    var dynamicStyle, size;
    window.viewportSize = 'desktop';
    if (window.getComputedStyle) { // IE 8 doesn't support this method. Because it sucks.
      // Chrome 33+ returns null for pseudo element contents when the pseudo element is hidden.
      dynamicStyle = $('<style>body:after{display: block;}</style>');
      dynamicStyle.appendTo('head');

      size = window.getComputedStyle(document.body, ':after').content;
      dynamicStyle.remove();

      return window.viewportSize = size.match(/\w+/)[0]; // Firefox includes extra quotes
    }
  };

  // Fires on every window resize
  $(window).on('resize', window.setViewportSize);

  // Fire now, to init window.viewportSize
  window.setViewportSize();
})(jQuery);
