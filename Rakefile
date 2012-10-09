desc "Run the development server"
task :server do
  exec "bundle exec ruby sassmeister.rb -p 3000"
end

desc "Compile the app's Sass"
task "assets:precompile" do
  system("compass compile")
end