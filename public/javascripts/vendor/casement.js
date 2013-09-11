/*!
 * Casement.js jQuery plugin
 * Author: @jed_foster
 * Project home: jedfoster.github.io/Casement.js
 * Licensed under the MIT license
 */

;(function($) {

  var $handle = sash_id = null;
  var casementSettings = JSON.parse(localStorage.getItem('casementSettings')) || {};

  var defaults = {
        split: 'vertical',
        onDragStart: function(){},
        onDragEnd: function(){},
        onDrag: function(){}
      };

  function Casement( element, options ) {
    this.element = element;

    this.options = $.extend( {}, defaults, options) ;

    this._defaults = defaults;

    this.init();
  }

  Casement.prototype = {
    parentWidth: null,
    parentHeight: null,
    parentOffset: {},

    init: function() {
      var $this = this,
          $el = $($this.element),
          columns = $el.children().length,
          paneSize = ( 100 / columns );


      $el.css({position: 'absolute', top: 0, right: 0, bottom: 0, left: 0});
      this.parentWidth =  $el.innerWidth();
      this.parentHeight = $el.innerHeight();
      this.parentOffset = $el.offset();

      if(this.options.split == 'horizontal') {
        $el.children().each(function(index) {
          var guid = $.fn.casement.guid++,
              settings = casementSettings[guid] || {x:null,y:null},
              nextSettings = casementSettings[guid + 1] || {x:null,y:null};

          $(this).data('casement_guid', guid);

          if (index == columns - 1) {
            nextSettings.y = 100;
          }

          var bottom = 100 - nextSettings.y;

          $(this).css({
            // width: paneSize + '%',
            top: ( settings.y || (paneSize * index)) + '%',
            bottom: ( (bottom == 100 ? false : bottom) || Math.abs(paneSize * (columns - (index + 1)))) + '%',
            position: 'absolute'
          });

          if(index !== columns - 1) {
            var id = 'sash-x' + (index + 1) + '-' + guid;

            $('<div/>').addClass('horizontal sash').css({
              top: ( nextSettings.y || (paneSize * (index + 1))) + '%',
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
        $el.children().each(function(index) {
          var guid = $.fn.casement.guid++,
              settings = casementSettings[guid] || {x:null,y:null},
              nextSettings = casementSettings[guid + 1] || {x:null,y:null};

          $(this).data('casement_guid', guid);

          if (index == columns - 1) {
            nextSettings.x = 100;
          }

          var right = 100 - nextSettings.x;

          $(this).css({
            // width: paneSize + '%',
            left: ( settings.x || (paneSize * index)) + '%',
            right: ( (right == 100 ? false : right) || Math.abs(paneSize * (columns - (index + 1)))) + '%',
            position: 'absolute'
          });

          if(index !== columns - 1) {
            var id = 'sash-y' + (index + 1) + '-' + guid;

            $('<div/>').addClass('vertical sash').css({
              left: ( nextSettings.x || (paneSize * (index + 1))) + '%',
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
          $handle = null;

          if( ! $(event.target).hasClass('sash') ) {
            event.stopPropagation();
            return false;
          }

          $handle = $(event.target);

          $this.options.onDragStart($handle, event);
          return false;
        }
      })
      .bind("mouseup.casement touchend.casement", function (e) {
        $handle = null;

        $this.options.onDragEnd($handle, event);
      })
      .bind("mousemove.casement touchmove.casement", function(event) {
        if ($handle !== null) {
          $this.resize($handle, { top: event.pageY, left: event.pageX });

          $this.options.onDrag($handle, event);
          return false;
        }
      });

      return this;
    },

    widthPercentage: function(int) {
      return  Math.abs( int /  ( this.parentWidth * 0.01 ) );
    },

    heightPercentage: function(int) {
      return  Math.abs( int /  ( this.parentHeight * 0.01 ) );
    },

    resize: function(handle, offset) {
      var settings = {
        x: null,
        y: null
      };

      if($(handle).hasClass('horizontal')) {
        if(offset.top <= handle.prev().offset().top ||
             offset.top >= (handle.next().offset().top - this.parentOffset.top + handle.next().outerHeight()) ) {
          return false;
        }

        var newHandleOffset = this.heightPercentage(offset.top - this.parentOffset.top);
        handle.css({top: newHandleOffset + '%'});
        handle.prev().css({bottom: (100 - newHandleOffset) + '%'});
        handle.next().css({ top: newHandleOffset + '%' });

        settings.y = newHandleOffset;
      }
      if($(handle).hasClass('vertical')) {
        if(offset.left <= handle.prev().offset().left ||
             offset.left >= (handle.next().offset().left - this.parentOffset.left + handle.next().outerWidth()) ) {
          return false;
        }

        var newHandleOffset = this.widthPercentage(offset.left - this.parentOffset.left);
        handle.css({left: newHandleOffset + '%'});
        handle.prev().css({right: (100 - newHandleOffset) + '%'});
        handle.next().css({ left: newHandleOffset + '%' });

        settings.x = newHandleOffset;
      }


      casementSettings[handle.next().data('casement_guid')] = settings;
      localStorage.setItem('casementSettings', JSON.stringify(casementSettings));
    },

    destroy: function() {
      var $this = this,
          $el = $($this.element);

      $el.children('.sash').remove();
      $el.children().removeAttr('style');
      // Remove data
      $($this.element).removeData();
    }
  },

  $.fn.casement = function( options ) {
    var args = arguments;
    if (options === undefined || typeof options === 'object') {
      return this.each(function () {
        if (!$.data(this, 'plugin_casement')) {
          $.data(this, 'plugin_casement', new Casement( this, options ));
        }
      });
    } else if (typeof options === 'string' && options[0] !== '_' && options !== 'init') {
      return this.each(function () {
        var instance = $.data(this, 'plugin_casement');
        if (instance instanceof Casement && typeof instance[options] === 'function') {
          instance[options].apply( instance, Array.prototype.slice.call( args, 1 ) );
        }
      });
    }
  };


  $.fn.casement.guid = $.fn.casement.guid || 0;
})(jQuery);