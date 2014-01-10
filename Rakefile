desc "Run the app's server in either development or production mode"
task :server do
  environment = 'development'

  if ARGV.last.match(/(development|production)/)
    environment = ARGV.last
  end

  Rake::Task["assets:precompile"].invoke

  puts "Starting SassMeister in #{environment.upcase} mode..."

  system("bundle exec rackup config.ru -p 3000 -E #{environment}")

  task environment.to_sym do ; end
end


# Heroku will run this task as part of the deployment process.
desc "Compile the app's Sass"
task "assets:precompile" do
  system("bundle exec jammit --force")
  system("bundle exec compass compile -e production")
end



