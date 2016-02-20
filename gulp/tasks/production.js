var gulp = require('gulp');

// Run this to compress all the things!
gulp.task('production', function(){
  process.env.NODE_ENV = 'production'; 
  gulp.start(['markup', 'minifyCss', 'uglifyJs'])
});

