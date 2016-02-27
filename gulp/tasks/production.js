var gulp = require('gulp');
var runSequence = require('run-sequence');
var config  = require('../config').production
var rev = require('gulp-rev');
var del     = require('del');

gulp.task('hashify', function() {
  return gulp.src([config.jsSrc, config.cssSrc], {base: config.dest})
    .pipe(rev())
    .pipe(gulp.dest(config.dest ))
    .pipe(rev.manifest())
    .pipe(gulp.dest(config.dest));
});

gulp.task('clean', function (cb) {
  del(config.dest + '/rev-manifest.json');
  return del(config.delSrc, cb);
});

// Run this to compress all the things!
gulp.task('production', function(callback){
  process.env.NODE_ENV = 'production'; 
  runSequence('clean', 'minifyCss', 'uglifyJs', 'hashify', 'markup', callback);
});

