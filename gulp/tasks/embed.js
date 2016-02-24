var gulp = require('gulp');
var config = require('../config').embed;
var coffee = require('gulp-coffee');
var sourcemaps   = require('gulp-sourcemaps');
var handleErrors = require('../util/handleErrors');

gulp.task('embed', function() {
  return gulp.src(config.src)
    // .pipe(sourcemaps.init())
    .pipe(coffee(config.settings))
    .on('error', handleErrors)
    // .pipe(sourcemaps.write())
    .pipe(gulp.dest(config.dest));
});

