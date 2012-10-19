# Those little ditties that Sinara needs to make the magic happen
# -----------------------------------------------------------------------
require 'rubygems'

# If you're using bundler, you will need to add this
require 'bundler/setup'

require 'sinatra'
require 'sinatra/partial'

require 'sass'
require 'compass'

require 'bourbon-compass'
require 'breakpoint'
require 'sassy-buttons'
require 'singularitygs'
require 'stipe'
require 'susy'


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


plugins = {
  "bourbon" => 'bourbon/bourbon',
  "breakpoint" => 'breakpoint',
  "compass" => 'compass',
  "sassy-buttons" => 'sassy-buttons',
  "singularity.gs" => 'singularitygs',
  "stipe" => './sass/stipe',  # This is a local manifest file that @imports all the Stipe modules
  "susy" => 'susy',
}


get '/' do
  @plugins = plugins

  @submit_text = ['Make some CSS brah!', 'Engage!', 'Show me the codez!', 'Machen Sie das CSS!', '&iexcl;Compilar!', 'Schnell!', 'Compile!', 'Go', 'Make me some CSS', '&#x421;&#x434;&#x435;&#x43B;&#x430;&#x442;&#x44C; CSS', 'Producent CSS', '&#x628;&#x646;&#x627;&#x626;&#x6CC;&#x6BA; CSS'].random
  
  @placeholder_text = ['What, you got nothin?', 'body { foo: derp }', 'Give me some Sass!', 'Type Sass to me.', 'Sass goes here.', 'How you doin\'?'].random

  erb :index
end


post '/compile' do
  Compass.sass_engine_options[:load_paths].each do |path|
    Sass.load_paths << path
  end

  if plugins.has_key?(params[:plugin])
    sass = "@import \"#{plugins[params[:plugin]]}\"#{";" if params[:syntax] == 'scss'}\n\n#{params[:sass]}"
  else
    sass = params[:sass]
  end

  begin
    send("#{params[:syntax]}".to_sym, sass.chomp, {:style => :"#{params[:output]}", :quiet => true})
      
  rescue Sass::SyntaxError => e
    status 200
    e.to_s
  end
end


get '/thankyou' do
  erb :thankyou
end