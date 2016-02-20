var gulp = require('gulp');
var config = require('../config').webpack;
var webpack = require('webpack-stream');
var named = require('vinyl-named');

var entries = Object.keys(config.entry).map(function (key) {return config.entry[key]});

gulp.task('webpack', ['yaml'], function(callback) {
  return gulp.src(entries)
  .pipe(named())
  .pipe(webpack(config))
  .pipe(gulp.dest(config.output.path));
});

