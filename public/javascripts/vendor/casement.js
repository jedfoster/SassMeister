/*!
 * Casement.js jQuery plugin
 * Author: @jed_foster
 * Project home: jedfoster.github.io/Casement.js
 * Licensed under the MIT license
 */

;(function($) {

  var $dragging = sash_id = parentHeight = null;

  var casement = 'casement',
      defaults = {
        split: 'vertical',
        onDragStart: function(){},
        onDragEnd: function(){},
        onDrag: function(){}
      };

  function Casement( element, options ) {
    this.element = element;

    this.options = $.extend( {}, defaults, options) ;

    this._defaults = defaults;
    this._name = casement;

    this.init();
  }

  Casement.prototype = {
    parentWidth: null,
    parentHeight: null,
    parentOffset: {},

    init: function() {
      var $this = this,
          columns = $($this.element).children().length,
          paneSize = ( 100 / columns );

      $($this.element).css({position: 'absolute', top: 0, right: 0, bottom: 0, left: 0});
      this.parentWidth = $($this.element).innerWidth();
      this.parentHeight = $($this.element).innerHeight();
      this.parentOffset = $($this.element).offset();


      if(this.options.split == 'horizontal') {
        $($this.element).children().each(function(index) {
          $(this).css({
            // width: paneSize + '%',
            top: (paneSize * index) + '%',
            bottom: Math.abs(paneSize * (index -1)) + '%',
            position: 'absolute'
          });

          if(index !== columns - 1) {
            var id = 'sash-x' + (index + 1) + (Math.floor(Math.random() * 101));

            $('<div/>').addClass('horizontal sash').css({
              top: (paneSize * (index + 1)) + '%',
            }).attr('id',  id)
            .mouseenter(function() {
              sash_id = id;
            })
            .mouseleave(function() {
              sash_id = null;
            })
            .insertAfter($(this));
          }
        });
      }

      else {
        $($this.element).children().each(function(index) {
          $(this).css({
            // width: paneSize + '%',
            left: (paneSize * index) + '%',
            right: Math.abs(paneSize * (columns - (index + 1))      ) + '%',
            position: 'absolute'
          });

          if(index !== columns - 1) {
            var id = 'sash-y' + (index + 1) + (Math.floor(Math.random() * 101));

            $('<div/>').addClass('vertical sash').css({
              left: (paneSize * (index + 1)) + '%',
            }).attr('id', id)
            .mouseenter(function() {
              sash_id = id;
            })
            .mouseleave(function() {
              sash_id = null;
            })
            .insertAfter($(this));
          }
        });
      }

      $(document.documentElement).bind("mousedown.casement touchstart.casement", function (event) {
        if (sash_id !== null) {
          $dragging = null;

          if( ! $(event.target).hasClass('sash') ) {
            event.stopPropagation();
            return false;
          }

          $dragging = $(event.target);

          $this.options.onDragStart($dragging, event);
          return false;
        }
      })
      .bind("mouseup.casement touchend.casement", function (e) {
        $dragging = null;
        $('#sash_cover').hide();

        $this.options.onDragEnd($dragging, event);
      })
      .bind("mousemove.casement touchmove.casement", function(event) {
        if ($dragging !== null) {
          $('#sash_cover').show();

          $this.resize($dragging, { top: event.pageY, left: event.pageX });

          $this.options.onDrag($dragging, event);
          return false;
        }
      });
    },

    widthPercentage: function(int) {
      return  Math.abs( int /  ( this.parentWidth * 0.01 ) );
    },

    heightPercentage: function(int) {
      return  Math.abs( int /  ( this.parentHeight * 0.01 ) );
    },

    resize: function(handle, offset) {


      if($(handle).hasClass('horizontal')) {
        var newHandleOffset = this.heightPercentage(offset.top - this.parentOffset.top);
        handle.css({top: newHandleOffset + '%'});
        handle.prev().css({bottom: (100 - newHandleOffset) + '%'});
        handle.next().css({ top: newHandleOffset + '%' });
      }
      if($(handle).hasClass('vertical')) {
        var newHandleOffset = this.widthPercentage(offset.left - this.parentOffset.left);
        handle.css({left: newHandleOffset + '%'});
        handle.prev().css({right: (100 - newHandleOffset) + '%'});
        handle.next().css({ left: newHandleOffset + '%' });
      }
    },
  },

  $.fn[casement] = function( options ) {
    var args = arguments;
    if (options === undefined || typeof options === 'object') {
      return this.each(function () {
        if (!$.data(this, 'plugin_' + casement)) {
          $.data(this, 'plugin_' + casement, new Casement( this, options ));
        }
      });
    } else if (typeof options === 'string' && options[0] !== '_' && options !== 'init') {
      return this.each(function () {
        var instance = $.data(this, 'plugin_' + casement);
        if (instance instanceof Casement && typeof instance[options] === 'function') {
          instance[options].apply( instance, Array.prototype.slice.call( args, 1 ) );
        }
      });
    }
  }
})(jQuery);