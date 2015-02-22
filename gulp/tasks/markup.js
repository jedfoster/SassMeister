var gulp = require('gulp');
var config = require('../config').markup;
var jade = require('gulp-jade');

gulp.task('markup', function() {
  return gulp.src(config.src)
    .pipe(jade())
    .pipe(gulp.dest(config.dest));
});


