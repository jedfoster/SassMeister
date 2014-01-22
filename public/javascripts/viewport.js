(function($) {
  window.setViewportSize = function() {
    var size;
    window.viewportSize = 'desktop';
    if (window.getComputedStyle) {
      if(size = window.getComputedStyle(document.body, ':after').content.trim()) {
        return window.viewportSize = size;
      }
    }
  };

  $(window).on('resize', window.setViewportSize);

  window.setViewportSize();
})(jQuery);



