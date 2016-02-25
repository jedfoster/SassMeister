var gulp = require('gulp');
var config = require('../config').markup;
var jade = require('gulp-jade');
var mustache = require('gulp-mustache');
var yaml = require('js-yaml');
var fs   = require('fs');

gulp.task('markup', function() {
  var env = process.env.NODE_ENV || 'development';
  console.log(env);
  var data = yaml.safeLoad(fs.readFileSync(__dirname + '/../../config/config.yml', 'utf8'))[env];

  console.log(data);

  return gulp.src(config.src)
    .pipe(mustache(data, {tags: ['{%', '%}']}))
    .pipe(jade())
    .pipe(gulp.dest(config.dest));
});

