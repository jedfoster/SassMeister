desc 'Release the Kraken!'
task :deploy do
  Rake::Task['assets:precompile'].invoke

  system 'bundle exec s3_website push --site public'

  system 'git push heroku'
  system 'git push origin'
end


desc 'Compile Coffeescript'
task 'compile:coffee' do
  require 'execjs'

  Dir.mkdir('javascripts/compiled/') unless Dir.exists?('javascripts/compiled/')

  context = ExecJS.compile File.read('lib/coffee-script.js')

  Dir.glob('coffee/*.coffee').each do |file|
    name = file.gsub /(coffee\/|\.coffee)/, ''
    js = context.call 'CoffeeScript.compile', File.read(file)

    File.open("javascripts/compiled/#{name}.js", 'w') {|f| f.write(js) }
  end
end


desc 'Warm up the Redis cache'
task 'warm:cache' do
  require_relative 'sassmeister'
  require_relative 'lib/sassmeister/redis'
  require 'thor'

  class Utilities < Thor
    include Thor::Actions
  end

  utilities = Utilities.new
  app = SassMeisterApp.new
  
  # Pre-populate to ensure we have _something_
  compilers = SassMeister::Redis.new 'compilers'
  compilers.set_defaults '{"3.2":{"sass":"3.2","engine":"Ruby"},"3.3":{"sass":"3.3","engine":"Ruby"},"3.4":{"sass":"3.4","engine":"Ruby"},"lib":{"sass":"3","engine":"LibSass"}}'

  extensions = SassMeister::Redis.new 'extensions'
  extensions.set_defaults '{"Ark":{"homepage":"https://github.com/drewbolles/ark"},"Bitters":{"homepage":"https://github.com/jedfoster/bitters-compass"},
"Blend Modes":{"homepage":"https://github.com/heygrady/scss-blend-modes"},"Bootstrap Sass":{"homepage":"https://github.com/twbs/bootstrap-sass"},
"Bourbon":{"homepage":"https://github.com/jedfoster/bourbon-compass"},"Breakpoint":{"homepage":"https://github.com/Team-Sass/breakpoint"},
"Breakpoint Slicer":{"homepage":"https://github.com/lolmaus/breakpoint-slicer"},"Breakup":{"homepage":"https://github.com/bpscott/breakup"},
"Ceasar Easing":{"homepage":"https://github.com/jhardy/compass-ceaser-easing"},"Color Schemer":{"homepage":"https://github.com/scottkellum/color-schemer"},
"Compass":{"homepage":"http://compass-style.org"},"Compass Inuit":{"homepage":"http://github.com/stephenway/compass-intuit"},
"Compass Slideshow":{"homepage":"http://www.oddbird.net/"},"Fancy Buttons":{"homepage":"http://github.com/imathis/fancy-buttons"},
"Fittext":{"homepage":"http://www.bookcasey.com/fittext/"},"Foundation":{"homepage":"https://github.com/zurb/bower-foundation"},
"Grid Coordinates":{"homepage":"http://grid-coordinates.com/"},"Guff":{"homepage":"http://kenwheeler.github.io/guff/"},
"Harsh":{"homepage":"http://www.bookcasey.com/harsh/"},"Jacket":{"homepage":"http://github.com/robwierzbowski/jacket"},
"Modular Scale":{"homepage":"http://extension.com"},"Neat":{"homepage":"https://github.com/jedfoster/neat-compass"},
"Normalize SCSS":{"homepage":"https://github.com/JohnAlbin/normalize-scss"},
"Photoshop Drop Shadow":{"homepage":"https://github.com/heygrady/compass-photoshop-drop-shadow"},
"Responsive Calculator":{"homepage":"http://rwdcalc.com"},"Responsive Modular Scale":{"homepage":"http://github.com/gakimball/responsive-modular-scale"},
"Responsive Sass":{"homepage":"http://ntreadway.github.com/responsive-sass/welcome"},"Salsa":{"homepage":"http://tsi.github.com/Salsa/"},
"Sass List-Maps":{"homepage":"https://github.com/lunelson/sass-list-maps"},"Sassy Buttons":{"homepage":"http://www.jaredhardy.com/sassy-buttons"},
"Sassy Text Shadow":{"homepage":"http://sassymothereffingtextshadow.com"},"Scut":{"homepage":"http://davidtheclark.github.io/scut/"},
"Singularity Extras":{"homepage":"http://singularity.gs"},"Singularity Golden Grid":{"homepage":"https://github.com/hunterman/singularity-golden-grid"},
"Singularity.gs":{"homepage":"http://singularity.gs"},"Stipe":{"homepage":"https://github.com/Toadstool-Stipe/stipe"},
"Stitch":{"homepage":"https://github.com/anthonyshort/stitch-css"},"Susy":{"homepage":"http://susy.oddbird.net/"},"Toolkit":{"homepage":"https://github.com/Snugug/toolkit"},
"True":{"homepage":"http://ericsuzanne.com/true"},"YIQ Color Contrast":{"homepage":"https://github.com/timhettler/compass-yiq-color-contrast"},
"Zen Grids":{"homepage":"http://zengrids.com"},"Base.Sass":{"homepage":"https://github.com/jsw0528/base.sass"},
"CSShake":{"homepage":"https://github.com/elrumordelaluz/csshake"},"Color Hacker":{"homepage":"http://github.com/imathis/color-hacker"},
"Flint":{"homepage":"http://flint.gs"},"Garnish":{"homepage":"https://github.com/paulozoom/garnish"},"MathSass":{"homepage":"http://github.com/terkel/mathsass"},
"Position":{"homepage":"https://github.com/Undistraction/position"},"Quotation Marks":{"homepage":"http://quotation-marks.org"},
"Sass Color Helpers":{"homepage":"https://github.com/voxpelli/sass-color-helpers"},"Sassifaction":{"homepage":"https://github.com/sturobson/Sassifaction"},
"Sassy Maps":{"homepage":"https://github.com/Snugug/Sassy-Maps"},"Sassy-Gridlover":{"homepage":"https://github.com/hiulit/Sassy-Gridlover"},
"SassyBitwise":{"homepage":"http://github.com/HugoGiraudel/SassyBitwise"},"SassyCast":{"homepage":"https://github.com/HugoGiraudel/SassyCast/"},
"SassyJSON":{"homepage":"https://github.com/HugoGiraudel/SassyJSON/"},"SassyLists":{"homepage":"http://sassylists.com/"},
"SassyMatrix":{"homepage":"https://github.com/HugoGiraudel/SassyMatrix/"},"SassySort":{"homepage":"https://github.com/HugoGiraudel/SassySort/"},
"SassyStrings":{"homepage":"https://github.com/HugoGiraudel/SassyStrings"},"Singularity Quick Spanner":{"homepage":"https://github.com/lolmaus/singularity-quick-spanner"},
"Sunglass":{"homepage":"https://github.com/devatrox/Sunglass"},"Typecsset":{"homepage":"https://github.com/csswizardry/typecsset"},
"Typesettings":{"homepage":"https://github.com/ianrose/typesettings"},"UtilityBelt":{"homepage":"https://github.com/dmtintner/UtilityBelt"}}'

  unless app.helpers.build_compiler_menu
    utilities.say_status('error', 'Could not build compiler menu', :red)
  end

  unless app.helpers.build_extension_info_list
    utilities.say_status('error', 'Could not build extension info list', :red)
  end
end


# Heroku will run this task as part of the deployment process.
desc 'Compile the app\'s Sass'
task 'assets:precompile' do
  require 'yaml'
  require 'digest/sha1'

  Rake::Task['warm:cache'].invoke

  Dir.mkdir('public/js/') unless Dir.exists? 'public/js/'

  system 'rm public/css/*'
  system 'rm public/js/*'

  Rake::Task['compile:coffee'].invoke

  system 'bundle exec jammit --force'
  system 'bundle exec compass compile --force -e production'

  assets = YAML.load_file 'config/assets.yml'
  manifest = {}

  assets['javascripts'].each do |js|
    file = File.read "public/js/#{js[0]}.js"
    sha1 = Digest::SHA1.hexdigest(file).slice(0..15)
 
    manifest[js[0]] = sha1

    File.open("public/js/#{js[0]}-#{sha1}.js", 'w') {|f| f.write(file) }
  end

  file = File.read 'public/css/style.css'
  sha1 = Digest::SHA1.hexdigest(file).slice(0..15)

  manifest['style'] = sha1

  File.open("public/css/style-#{sha1}.css", 'w') {|f| f.write(file) }

  File.open("config/asset-manifest.yml", 'w') {|f| f.write(manifest.to_yaml) }
end


require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = "#{File.join(File.dirname(File.realpath(__FILE__)), 'spec')}/*_spec.rb"
end

task t: :test



desc 'Compile the app\'s icons to an SVG sprite'
task 'svg:sprite' do
  require 'nokogiri'

  @doc = Nokogiri::XML::Document.new

  @svg = @doc.add_child Nokogiri::XML::Node.new "svg", @doc

  @svg['xmlns'] = 'http://www.w3.org/2000/svg'

  Dir.glob('svg/*.svg').each do |file|
    node = Nokogiri::XML(File.open(file)).css('svg').first

    id = file.split('/')[1].split('.')[0]

    symbol = Nokogiri::XML::Node.new "symbol", @doc
    symbol['viewBox'] = node['viewBox']
    symbol['id'] = id
    symbol << "<title>#{id}</title>"
    symbol << node.children.to_xml.strip

    @svg.add_child(symbol)
  end

  File.open("public/img/icons.svg", 'w') {|f| f.write(@doc.to_xml.gsub(/(\n|\t|\s{2,})/, '')) }
end
