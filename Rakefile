require 'yaml'
require 'thor'

desc "Run the app's server in either development or production mode"
task :server do
  environment = 'development'

  if ARGV.last.match(/(development|production)/)
    environment = ARGV.last
  end

  Rake::Task["assets:precompile"].invoke

  puts "Starting SassMeister in #{environment.upcase} mode..."

  exec "bundle exec rackup config.ru -p 3000 -E #{environment}"

  task environment.to_sym do ; end
end


# Heroku will run this task as part of the deployment process.
desc "Compile the app's Sass"
task "assets:precompile" do
  system("bundle exec jammit --force")
  system("bundle exec compass compile")
end


desc "Update bundled gems. Use this in place of bundle update"
task "bundle:update" do
  plugins = YAML.load_file("config/plugins.yml")
  gemfile = File.new('Gemfile').read

  plugins.each do |plugin|
    if ! gemfile.match(/^gem '#{plugin.last[:gem]}'/)
      puts "Adding #{plugin.last[:gem]} to Gemfile..."
      Utilities.new.append('Gemfile', "\ngem '#{plugin.last[:gem]}'")
      Utilities.new.append('./lib/plugins.rb', "\nrequire '#{plugin.last[:gem]}'")
    end
  end
  
  exec "bundle update"
end


class Utilities < Thor
  include Thor::Actions

  no_tasks do
    def append(file, string)
       append_file file, string, {:verbose => false}
    end
  end
end