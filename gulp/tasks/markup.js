var gulp = require('gulp');
var config = require('../config').markup;
var jade = require('gulp-jade');
var mustache = require('gulp-mustache');

gulp.task('markup', ['yaml'], function() {
  var env = process.env.NODE_ENV || 'development';
  var data = require('../../config/config.json')[env];

  return gulp.src(config.src)
    .pipe(jade())
    .pipe(mustache(data, {tags: ['{%', '%}']}))
    .pipe(gulp.dest(config.dest));
});

