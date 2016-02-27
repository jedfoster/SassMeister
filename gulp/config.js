var dest = './public';
var src = './client';

module.exports = {
  javascript: {
    src: src + '/**/*.{js,coffee}'
  },
  sass: {
    src: src + '/**/*.{sass,scss}',
    dest: dest,
    settings: {
      indentedSyntax: true, // Enable .sass syntax!
      imagePath: 'images', // Used by the image-url helper
      // sourceMapRoot: src,
      includePaths: [
        src,
        src + '/sassmeister'
      ]
    }
  },
  markup: {
    src: [src + '/**/*.jade', '!' + src + '/**/_*.jade'],
    watchSrc: src + '/**/*.jade',
    dest: dest
  },
  webpack: {
    entry: {
      app: src + '/js/app.coffee',
      embed: src + '/js/embed.coffee'
    },
    output: {
      path: __dirname + '/../public/js/',
      filename: '[name].js'
    },
    module: {
      loaders: [
        { test: /\.jade$/, loader: "jade" },
        { test: /\.json$/, loader: 'json' },
        { test: /\.coffee$/, loader: "coffee" }
      ]
    },
    resolve: {
      extensions: ['', '.js', '.json', '.coffee']
    }
  },
  embed: {
    src: [src + '/js/embed.coffee'],
    dest: dest + '/js',
    settings: {
      bare: false
    }
  },
  production: {
    cssSrc: dest + '/css/*.css',
    jsSrc: dest + '/js/*.js',
    delSrc: [dest + '/js/*', dest + '/css/*'],
    dest: dest
  }
};

