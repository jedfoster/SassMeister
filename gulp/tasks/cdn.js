var gulp = require('gulp');
var awspublish = require('gulp-awspublish');
var cloudfront = require('gulp-cloudfront-invalidate-aws-publish');
var gzip = require('gulp-gzip');
var config  = require('../config').production

gulp.task('cdn', function(callback) {
  if(! (process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY && process.env.AWS_S3_BUCKET && process.env.AWS_CLOUDFRONT_DISTRIBUTION_ID) ) {
    return callback();
  }

  var aws = {
    region: 'us-west-2',
    key: process.env.AWS_ACCESS_KEY_ID,
    secret: process.env.AWS_SECRET_ACCESS_KEY,
    bucket: process.env.AWS_S3_BUCKET,
    distribution: process.env.AWS_CLOUDFRONT_DISTRIBUTION_ID
  };

  var publisher = awspublish.create({
    region: aws.region,
    accessKeyId: aws.key,
    secretAccessKey: aws.secret,
    params: {
      Bucket: aws.bucket
    }
  });

  var cfSettings = {
    distribution: aws.distribution,
    accessKeyId: aws.key,
    secretAccessKey: aws.secret
  }

  return gulp.src(config.dest + '/**')
    .pipe(awspublish.gzip())

    // publisher will add Content-Length, Content-Type and headers specified above
    // If not specified it will set x-amz-acl to public-read by default
    .pipe(publisher.publish(config.cdn.headers))

    // print upload updates to console
    .pipe(awspublish.reporter({
      states: ['create', 'update']
    }))

    .pipe(cloudfront(cfSettings));
});

