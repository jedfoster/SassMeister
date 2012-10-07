# Those little ditties that Sinara needs to make the magic happen
# -----------------------------------------------------------------------
require 'rubygems'
require 'compass'
require 'sass'
require 'stipe'
require 'bourbon'

# If you're using bundler, you will need to add this
require 'bundler/setup'

require 'sinatra'
require 'sinatra/partial'

set :partial_template_engine, :erb

helpers do
  include ERB::Util
  alias_method :code, :html_escape
end


configure do
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config.rb'))
end

# at a minimum, the main sass file must reside within the ./views directory. here, we create a ./views/stylesheets directory where all of the sass files can safely reside.
get '/stylesheets/:name.css' do
  content_type 'text/css', :charset => 'utf-8'
  scss(:"../sass/#{params[:name]}", Compass.sass_engine_options )
end


get '/' do
  erb :index
end


post '/compile' do
  Compass.sass_engine_options[:load_paths].each do |path|
    Sass.load_paths << path
  end


  if params[:plugin] == 'bourbon'
    plugin = "@import \"bourbon/bourbon\""
  elsif params[:plugin] == 'compass'
    plugin = "@import \"compass\""
  elsif params[:plugin] == 'stipe'
    plugin = "@import \"./sass/stipe\""
  else
    plugin = ''
  end


  if ! plugin.empty? and params[:syntax] == 'scss'
    sass = "#{plugin};\n\n#{params[:sass]}"
  else
    sass = "#{plugin}\n\n#{params[:sass]}"
  end


  begin
    send("#{params[:syntax]}".to_sym, sass.chomp, {:style => :"#{params[:output]}"})
  rescue Sass::SyntaxError => e
    status 200
    e.to_s
  end
end