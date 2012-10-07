# Those little ditties that Sinara needs to make the magic happen
# -----------------------------------------------------------------------
require 'rubygems'
require 'compass'
require 'sass'
require 'tempfile'

require 'stipe'               # installed as a gem

# If you're using bundler, you will need to add this
require 'bundler/setup'

require 'sinatra'
require 'sinatra/partial'

set :partial_template_engine, :erb

# Helpers to add a new horn section to the band
# -----------------------------------------------------------------------
helpers do
  include ERB::Util
  alias_method :code, :html_escape
end


configure do
  Compass.add_project_configuration(File.join(Sinatra::Application.root, 'config.rb'))


  # disable :raise_errors
  # disable :show_exceptions
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
  begin
    send("#{params[:syntax]}".to_sym, params[:sass], {:style => :"#{params[:output]}"})
  rescue Sass::SyntaxError => e
    status 200
    e.to_s
  end
end

error do
  'Sorry there was a nasty error - ' + env['sinatra.error'].name
end