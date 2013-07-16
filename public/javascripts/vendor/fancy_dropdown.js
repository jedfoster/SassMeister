var Modernizr = {
  csstransitions: true
};

/**
 * jquery.dropdown.js v1.0.0
 * http://www.codrops.com
 *
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 *
 * Copyright 2012, Codrops
 * http://www.codrops.com
 */
;( function( $, window, undefined ) {

	'use strict';

	$.DropDown = function( options, element ) {
		this.$el = $( element );
		this._init( options );
		this.value = function() {
		  return this.$el[0].value;
		}
	};

	// the options
	$.DropDown.defaults = {
		speed : 300,
		easing : 'ease',
		// delay between each option animation
		delay : 0,
		onOptionSelect : function(opt) { return false; },
    onOpen : function(opt) { return true; },
    onClose : function(opt) { return true; }
	};

	$.DropDown.prototype = {
		_init : function( options ) {
			// options
			this.options = $.extend( true, {}, $.DropDown.defaults, options );
			this._layout();
			this._initEvents();
		},

		_layout : function() {
			var self = this;
      this.minZIndex = 10;
			this._transformSelect();
			this.opts = this.listopts.find( 'li' );
			this.optsCount = this.opts.length;
			this.size = { width : this.dd.width(), height : this.dd.height() };
			
			var elName = this.$el.attr( 'name' ), elId = this.$el.attr( 'id' ),
				inputName = elName !== undefined ? elName : elId !== undefined ? elId : 'fancy_dropdown-' + ( new Date() ).getTime();

			this.inputEl = $( '<input type="hidden" name="' + inputName + '"></input>' ).insertAfter( this.selectlabel );
			
      this.selectlabel.css( 'z-index', this.minZIndex + this.optsCount );
			this._positionOpts();
			if( Modernizr.csstransitions ) {
				setTimeout( function() { self.opts.css( 'transition', 'all ' + self.options.speed + 'ms ' + self.options.easing ); }, 25 );
			}
		},

		_transformSelect : function() {
			var optshtml = '', selectlabel = '', value = -1;;
			this.$el.children( 'option' ).each( function() {

				var $this = $( this ),
					val = isNaN( $this.attr( 'value' ) ) ? $this.attr( 'value' ) : Number( $this.attr( 'value' ) ) ,
					classes = $this.attr( 'class' ),
					selected = $this.attr( 'selected' ),
					label = $this.text();

          if( val !== -1 ) {
            optshtml += 
        		  classes !== undefined ? 
        			  '<li data-value="' + val + '"><span class="' + classes + '">' + label + '</span></li>' :
        				'<li data-value="' + val + '"><span>' + label + '</span></li>';
        	}

        	if( selected ) {
        	  selectlabel = label;
        		value = val;
        	}
			} );

			this.listopts = $('<ul/>').append( optshtml );
      this.listopts = $('<div/>').append( this.listopts );
      
      // $(this.listopts).wrap();
			
			this.selectlabel = $( '<span/>' ).append( selectlabel );
			this.dd = $( '<div class="fancy_dropdown"/>' ).append( this.selectlabel, this.listopts ).insertAfter( this.$el );
			this.$el.remove();
		},

		_positionOpts : function( anim ) {
      var self = this;

      this.listopts.css( {'top': this.size.height + 1, 'left': -9000, 'width': '100%'} );
      $('li', this.opts)
				.each( function( i ) {
					$( this ).css( {
            //zIndex : self.minZIndex + self.optsCount - 1 - i,
            //top : 0,
						//left : 0,
						opacity : 0,
						transform : 'none'
					} );
				} );

      this.opts
    	  .eq( this.optsCount - 1 )
      	.css( { transform : 'none' } )
      	.end()
      	.eq( this.optsCount - 2 )
      	.css( { transform : 'none' } )
      	.end()
      	.eq( this.optsCount - 3 )
      	.css( { transform : 'none' } );
		},

		_initEvents : function() {			
			var self = this;
			
			this.selectlabel.on( 'mousedown.dropdown', function( event ) {
				self.opened ? self.close() : self.open();
				return false;
			} );
			
			//this.dd.on( 'mouseleave.dropdown', function( event ) {
			//	self.opened ? self.close() : self.open();
			//	return false;
			//} );
			
      // console.log(this);
			

      //function test_active_click(evt) {
      //  
      //};
      
      
      $(document).on('click', function(evt) {
        //return test_active_click(evt);
        if ($(evt.target).parents(self.dd).length) {
          return false;
        } else {
          self.close();
  				return false;
        }
      });
			
			
			
			

			this.opts.on( 'click.dropdown', function() {
				if( self.opened ) {
					var opt = $( this );
					self.options.onOptionSelect( opt );
					self.inputEl.val( opt.data( 'value' ) );
					self.selectlabel.html( opt.html() );
					self.close();
				}
			} );
		},

		open : function() {
			var self = this;
			if( ! this.options.onOpen( $( self ) ) ) {
			  return false;
			}
			this.dd.toggleClass( 'active' );
			this.listopts.css( {'left': 0 } );
			this.opts.each( function( i ) {

				$( this ).css( {
					opacity : 1,
					top : ( i + 1 ) * self.size.height,
					transitionDelay : self.options.delay && Modernizr.csstransitions ? ( ( self.optsCount - 1 - i ) * self.options.delay ) + 'ms' : 0
				} );
			} );
			this.opened = true;
		},

		close : function() {
			var self = this;
      if( ! this.options.onClose( $( self ) ) ) {
			  return false;
			}
			this.dd.toggleClass( 'active' );
			if( this.options.delay && Modernizr.csstransitions ) {
				this.opts.each( function( i ) {
					$( this ).css( { 'transition-delay' : ( i * self.options.delay ) + 'ms' } );
				} );
			}
			this._positionOpts( true );
			this.opened = false;
		}
	}

	$.fn.dropdown = function( options ) {
		var instance = $.data( this, 'dropdown' );
		if ( typeof options === 'string' ) {
			var args = Array.prototype.slice.call( arguments, 1 );
			this.each(function() {
				instance[ options ].apply( instance, args );
			});
		}
		else {
			this.each(function() {
				instance ? instance._init() : instance = $.data( this, 'dropdown', new $.DropDown( options, this ) );
			});
		}
		return instance;
	};
} )( jQuery, window );
