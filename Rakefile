desc 'Release the Kraken!'
task :deploy do
  Rake::Task['assets:precompile'].invoke

  system('bundle exec s3_website push --site public')

  system('git push heroku')
  system('git push origin')
end


desc 'Compile Coffeescript'
task 'compile:coffee' do
  require 'execjs'

  Dir.mkdir('javascripts/compiled/') unless Dir.exists? 'javascripts/compiled/'

  context = ExecJS.compile File.read('lib/coffee-script.js')

  Dir.glob('coffee/*.coffee').each do |file|
    name = file.gsub('coffee/', '').gsub('.coffee', '')
    js = context.call('CoffeeScript.compile', File.read(file))

    File.open("javascripts/compiled/#{name}.js", 'w') {|f| f.write(js) }
  end
end

# Heroku will run this task as part of the deployment process.
desc 'Compile the app\'s Sass'
task 'assets:precompile' do
  require 'yaml'
  require 'digest/sha1'

  Dir.mkdir('public/js/') unless Dir.exists? 'public/js/'

  system('rm public/css/*')
  system('rm public/js/*')

  Rake::Task['compile:coffee'].invoke

  system('bundle exec jammit --force')
  system('bundle exec compass compile --force -e production')

  assets = YAML.load_file("config/assets.yml")
  manifest = {}

  assets['javascripts'].each do |js|
    file = File.read("public/js/#{js[0]}.js")
    sha1 = Digest::SHA1.hexdigest(file).slice(0..15)
 
    manifest[js[0]] = sha1

    File.open("public/js/#{js[0]}-#{sha1}.js", 'w') {|f| f.write(file) }
  end

  file = File.read('public/css/style.css')
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

