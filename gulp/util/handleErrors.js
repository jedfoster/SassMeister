module.exports = function() {
  var args = Array.prototype.slice.call(arguments);

  // Keep gulp from hanging on this task
  this.emit('end');
};
