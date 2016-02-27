var gulp = require('gulp');
var config = require('../config').webpack;
var webpack = require('webpack-stream');
var named = require('vinyl-named');
var mustache = require('gulp-mustache');
var yaml = require('js-yaml');
var fs   = require('fs');


var entries = Object.keys(config.entry).map(function (key) {return config.entry[key]});

gulp.task('webpack', function(callback) {
  var env = process.env.NODE_ENV || 'development';
  var data = yaml.safeLoad(fs.readFileSync(__dirname + '/../../config/config.yml', 'utf8'))[env];

  return gulp.src(entries)
    .pipe(named())
    .pipe(webpack(config))
    .pipe(mustache(data, {tags: ['{%', '%}']}))
    .pipe(gulp.dest(config.output.path));
});

