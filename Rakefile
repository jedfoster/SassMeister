desc 'Release the Kraken!'
task :deploy do
  Rake::Task['assets:precompile'].invoke

  system('bundle exec s3_website push --site public')

  system('git push heroku')
  system('git push origin')
end

desc 'Run the app\'s server in either development or production mode'
task :server do
  environment = 'development'

  if ARGV.last.match(/(development|production)/)
    environment = ARGV.last
  end

  Rake::Task['assets:precompile'].invoke

  puts "Starting SassMeister in #{environment.upcase} mode..."

  system("bundle exec rackup config.ru -p 3000 -E #{environment}")

  task environment.to_sym do ; end
end


# Heroku will run this task as part of the deployment process.
desc 'Compile the app\'s Sass'
task 'assets:precompile' do
  require 'execjs'
  require 'yaml'
  require 'digest/sha1'

  Dir.mkdir('public/js/') unless Dir.exists? 'public/js/'

  system('rm public/css/*')
  system('rm public/js/*')

  source = File.read('coffee/embed.coffee')

  context = ExecJS.compile File.read('lib/coffee-script.js')
  js = context.call('CoffeeScript.compile', source)

  File.open('public/js/embed.js', 'w') {|f| f.write(js) }

  system('bundle exec jammit --force')
  system('bundle exec compass compile --force -e production')

  assets = YAML.load_file("config/assets.yml")

  assets['javascripts'].each do |js|
    file = File.read("public/js/#{js[0]}.js")
    sha1 = Digest::SHA1.hexdigest(file).slice(0..15)
 
    File.open("config/#{js[0]}.txt", 'w') {|f| f.write(sha1) }
    File.open("public/js/#{js[0]}-#{sha1}.js", 'w') {|f| f.write(file) }
  end

  file = File.read('public/css/style.css')
  sha1 = Digest::SHA1.hexdigest(file).slice(0..15)

  File.open('config/style.txt', 'w') {|f| f.write(sha1) }
  File.open("public/css/style-#{sha1}.css", 'w') {|f| f.write(file) }

end
