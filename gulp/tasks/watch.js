var gulp     = require('gulp');
var config   = require('../config');

gulp.task('watch', function(callback) {
  gulp.watch(config.javascript.src, ['webpack']);
  gulp.watch(config.sass.src,   ['sass']);
  gulp.watch(config.markup.watchSrc, ['markup', 'webpack']);
  // Watchify will watch and recompile our JS, so no need to gulp.watch it
});

