# Those little ditties that Sinara needs to make the magic happen
# -----------------------------------------------------------------------
require 'rubygems'
require 'compass'
require 'sass'
require 'stipe'
# require 'bourbon-compass'
require '../bourbon-compass/lib/bourbon-compass.rb'

# If you're using bundler, you will need to add this
require 'bundler/setup'

require 'sinatra'
require 'sinatra/partial'

set :partial_template_engine, :erb

helpers do
  include ERB::Util
  alias_method :code, :html_escape
  
  
  # From: http://rubyquicktips.com/post/2625525454/random-array-item
  class Array
    def random
      shuffle.first
    end
  end
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
  @submit_text = ['Make some CSS brah!', 'Engage!', 'Show me the codez!', 'Machen Sie das CSS!', '&iexcl;Compilar!', 'Schnell!', 'Compile!', 'Go', 'Make me some CSS', '&#x421;&#x434;&#x435;&#x43B;&#x430;&#x442;&#x44C; CSS', 'Producent CSS', '&#x628;&#x646;&#x627;&#x626;&#x6CC;&#x6BA; CSS'].random

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