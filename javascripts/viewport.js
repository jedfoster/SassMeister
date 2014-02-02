(function($) {
  window.setViewportSize = function() {
    var size;
    window.viewportSize = 'desktop';
    if (window.getComputedStyle) { // IE 8 doesn't support this method. Because it sucks.
      // Chrome 34 (dev) has a broken getComputedStyle, so size will actually be null
      if (size = window.getComputedStyle(document.body, ':after').content.trim()) {
        return window.viewportSize = size.match(/\w+/)[0]; // Firefox includes extra quotes
      }
    }
  };

  // Fires on every window resize
  $(window).on('resize', window.setViewportSize);

  // Fire now, to init window.viewportSize
  window.setViewportSize();
})(jQuery);
