var gulp = require('gulp');
var config = require('../config').markup;
var jade = require('gulp-jade');
var mustache = require('gulp-mustache');
var yaml = require('js-yaml');
var fs   = require('fs');
var replace = require('gulp-batch-replace');

gulp.task('jade', function() {
  return gulp.src(config.src)
    .pipe(jade())
    .pipe(gulp.dest(config.dest));
});

gulp.task('markup', ['jade'], function() {
  var env = process.env.NODE_ENV || 'development',
      data = yaml.safeLoad(fs.readFileSync(__dirname + '/../../config/config.yml', 'utf8'))[env],
      manifest = {},
      replacements = [];
  
  if (env != 'development') {
    manifest = JSON.parse(fs.readFileSync(config.dest + '/rev-manifest.json', 'utf8'));
    replacements = Object.keys(manifest).map(function (key) {return [key, manifest[key]]});
  }

  return gulp.src(config.dest + '/*.html')
    .pipe(replace([['{%&amp;', '{%&']]))
    .pipe(mustache(data, {tags: ['{%', '%}']}))
    .pipe(replace(replacements))
    .pipe(gulp.dest(config.dest));
});

