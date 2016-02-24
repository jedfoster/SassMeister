angular.module('angularResizable', [])
    .directive('resizable', function() {
        var toCall;
        function throttle(fun) {
            if (toCall === undefined) {
                toCall = fun;
                setTimeout(function() {
                    toCall();
                    toCall = undefined;
                }, 100);
            } else {
                toCall = fun;
            }
        }
        return {
            restrict: 'AE',
            scope: {
                rDirections: '@',
                rCenteredX: '=',
                rCenteredY: '=',
                rWidth: '=',
                rHeight: '=',
                rFlex: '=',
                rGrabber: '@',
                rDisabled: '@'
            },
            link: function(scope, element, attr) {
                var flexBasis = 'flexBasis' in document.documentElement.style ? 'flexBasis' :
                    'webkitFlexBasis' in document.documentElement.style ? 'webkitFlexBasis' :
                    'msFlexPreferredSize' in document.documentElement.style ? 'msFlexPreferredSize' : 'flexBasis';

                // register watchers on width and height attributes if they are set
                scope.$watch('rWidth', function(value){
                  value = value && value.indexOf('%') === -1 ? percentX(value) : value;
                  element[0].style[scope.rFlex ? flexBasis : 'width'] = value ? value : (scope.rWidth ? percentX(scope.rWidth) : null);
                });
                scope.$watch('rHeight', function(value){
                  value = value && value.indexOf('%') === -1 ? percentY(value) : value;
                  element[0].style[scope.rFlex ? flexBasis : 'height'] = value ? value : (scope.rWidth ? percentY(scope.rWidth) : null);
                });

                element.addClass('resizable');

                var style = window.getComputedStyle(element[0], null),
                    w,
                    h,
                    dir = scope.rDirections,
                    vx = scope.rCenteredX ? 2 : 1, // if centered double velocity
                    vy = scope.rCenteredY ? 2 : 1, // if centered double velocity
                    viewportX,
                    viewportY,
                    inner = scope.rGrabber ? scope.rGrabber : '<span></span>',
                    start,
                    dragDir,
                    axis,
                    info = {};

                var updateInfo = function(e) {
                    viewportX = document.documentElement.clientWidth;
                    viewportY = document.documentElement.clientHeight;
                    info.width = false; info.height = false;
                    var y = element[0].style[scope.rFlex ? flexBasis : 'width'], 
                        x = element[0].style[scope.rFlex ? flexBasis : 'height'];
                    if(axis === 'x')
                        info.width = x.indexOf('%') === -1 ? percentX(x) : x;
                    else
                        info.height = y.indexOf('%') === -1 ? percentY(y) : y;
                    info.id = element[0].id;
                    info.evt = e;
                };

                var percentX = function(value) {
                  return (value / (viewportX * .01)) + '%';
                };

                var percentY = function(value) {
                  return (value / (viewportY * .01)) + '%';
                };

                var dragging = function(e) {
                    var prop, value, offset = axis === 'x' ? start - e.clientX : start - e.clientY;
                    switch(dragDir) {
                        case 'top':
                            prop = scope.rFlex ? flexBasis : 'height';
                            value = h + (offset * vy);
                            element[0].style[prop] = percentY(value);
                            break;
                        case 'bottom':
                            prop = scope.rFlex ? flexBasis : 'height';
                            value = h - (offset * vy);
                            element[0].style[prop] = percentY(value);
                            break;
                        case 'right':
                            prop = scope.rFlex ? flexBasis : 'width';
                            value = w - (offset * vx);
                            element[0].style[prop] = percentX(value);
                            break;
                        case 'left':
                            prop = scope.rFlex ? flexBasis : 'width';
                            value = w + (offset * vx);
                            element[0].style[prop] = percentX(value);
                            break;
                    }
                    updateInfo(e);
                    throttle(function() { scope.$emit('angular-resizable.resizing', info);});
                };
                var dragEnd = function(e) {
                    updateInfo();
                    scope.$emit('angular-resizable.resizeEnd', info);
                    scope.$apply();
                    document.removeEventListener('mouseup', dragEnd, false);
                    document.removeEventListener('mousemove', dragging, false);
                    element.removeClass('no-transition');
                };
                var dragStart = function(e, direction) {
                    dragDir = direction;
                    axis = dragDir === 'left' || dragDir === 'right' ? 'x' : 'y';
                    start = axis === 'x' ? e.clientX : e.clientY;
                    w = parseInt(style.getPropertyValue('width'));
                    h = parseInt(style.getPropertyValue('height'));

                    //prevent transition while dragging
                    element.addClass('no-transition');

                    document.addEventListener('mouseup', dragEnd, false);
                    document.addEventListener('mousemove', dragging, false);

                    // Disable highlighting while dragging
                    if(e.stopPropagation) e.stopPropagation();
                    if(e.preventDefault) e.preventDefault();
                    e.cancelBubble = true;
                    e.returnValue = false;

                    updateInfo(e);
                    scope.$emit('angular-resizable.resizeStart', info);
                    scope.$apply();
                };

                scope.$watch("rDirections", function(directions) {
                  if(typeof directions === 'string') {
                    dir = directions.split(',');
                  }

                  var oldGrabbers = element[0].querySelectorAll('[class^="rg-"]');
                  var l = oldGrabbers.length;
                  for (i = 0; i < l; ++i) {
                    var grabber = oldGrabbers[i];
                    grabber.parentNode.removeChild(grabber)
                  }

                  dir.forEach(function (direction) {
                      var grabber = document.createElement('div');

                      // add class for styling purposes
                      grabber.setAttribute('class', 'rg-' + direction);
                      grabber.innerHTML = inner;
                      element[0].appendChild(grabber);
                      grabber.ondragstart = function() { return false; };
                      grabber.addEventListener('mousedown', function(e) {
                          var disabled = (scope.rDisabled === 'true');
                          if (!disabled && e.which === 1) {
                              // left mouse click
                              dragStart(e, direction);
                          }
                      }, false);
                  });
                });
            }
        };
    });
