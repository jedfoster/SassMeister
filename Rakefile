desc "Run the development server"
task :server do
  exec "bundle exec compass compile && bundle exec ruby sassmeister.rb -p 3000"
end

# Heroku will run this task as part of the deployment process.
desc "Compile the app's Sass"
task "assets:precompile" do
  system("compass compile")
end