var gulp    = require('gulp');
var config  = require('../config').production;
var size    = require('gulp-filesize');
var uglify  = require('gulp-uglify');
var rename    = require('gulp-rename');
var runSequence = require('run-sequence');

gulp.task('_uglify', function() {
  return gulp.src(config.jsSrc)
    .pipe(uglify())
    .pipe(rename({ suffix: '.min' }))
    .pipe(gulp.dest(config.dest + '/js/'))
    .pipe(size());
});

gulp.task('uglifyJs', function(callback) {
  return runSequence('webpack', '_uglify', callback);
});

