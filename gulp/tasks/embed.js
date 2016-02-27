var gulp    = require('gulp');
var config  = require('../config').production;
var rename    = require('gulp-rename');
var del     = require('del');

gulp.task('_embed', function(callback) {
  return gulp.src(config.dest + '/js/embed.min.js')
    .pipe(rename('embed.js'))
    .pipe(gulp.dest(config.dest + '/js/'));
});

gulp.task('embed', ['_embed'], function(cb) {
  return del(config.dest + '/js/embed.min.js', cb);
});

