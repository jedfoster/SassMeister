var gulp = require('gulp');
var config = require('../config').webpack;
var webpack = require('webpack-stream');
var named = require('vinyl-named');
var mustache = require('gulp-mustache');

var entries = Object.keys(config.entry).map(function (key) {return config.entry[key]});

gulp.task('webpack', ['yaml'], function(callback) {
  var env = process.env.NODE_ENV || 'development';
  var data = require('../../config/config.json')[env];

  return gulp.src(entries)
  .pipe(named())
  .pipe(webpack(config))
  .pipe(mustache(data, {tags: ['{%', '%}']}))
  .pipe(gulp.dest(config.output.path));
});

