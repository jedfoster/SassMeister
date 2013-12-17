(function($) {
  window.setViewportSize = function() {
    var size;
    window.viewportSize = 'desktop';
    if (window.getComputedStyle) {
      size = window.getComputedStyle(document.body, ':after').content;
      return window.viewportSize = size.match(/\w+/)[0];
    }
  };

  $(window).on('resize', window.setViewportSize);

  window.setViewportSize();
})(jQuery);



