var gulp = require('gulp');
var yaml = require('gulp-yaml');

gulp.task('yaml', function() {
  gulp.src('./config/config.yml')
    .pipe(yaml({space: 2}))
    .pipe(gulp.dest('./config/'))
});

