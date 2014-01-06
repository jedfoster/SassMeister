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

  system("bundle exec rackup config.ru -p 3000 -E #{environment}")

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
  about_list = []
  sass_input_list = []

  plugins.each do |plugin, info|
    about_list.push "<li><a href=\"#{info[:url]}\">#{plugin}</a></li>"

    if ! gemfile.match(/^gem '#{info[:gem]}'/)
      puts "Adding #{info[:gem]} to Gemfile..."
      Utilities.new.append('Gemfile', "\ngem '#{info[:gem]}'")
    end
  end

  Utilities.new.update_plugin_list('views/about.erb', about_list)

  stdout = `bundle update`

  puts stdout

  plugins.each do |plugin, info|
    version = stdout.scan(/#{info[:gem]} \((.+)\)/)[0][0].to_s

    sass_input_list.push "<li><a data-import=\"#{info[:import].to_s.gsub(/(\"|\[|\]|\s*)/, '')}\">#{plugin}</a>&nbsp;&nbsp;(v#{version})</li>"
  end

  Utilities.new.update_plugin_list('views/extensions.erb', sass_input_list)
  Utilities.new.update_sass_version(stdout.scan(/ sass \((.+?)\)/)[0][0].to_s)
end


class Utilities < Thor
  include Thor::Actions

  no_tasks do
    def append(file, string)
       append_file file, string, {:verbose => false}
    end

    def update_plugin_list(file, list)
      gsub_file file, /<ol>\s*(<li>.+?<\/li>\s*)+<\/ol>/, "<ol>\n\t\t#{list.join("\n\t\t")}\n\t</ol>"
    end

    def update_sass_version(version)
      gsub_file 'views/shared/_sass_input.erb', /<li>Sass&nbsp;&nbsp;\(v.+?\)/, "<li>Sass&nbsp;&nbsp;(v#{version})"
    end
  end
end