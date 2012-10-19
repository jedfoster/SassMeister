# Those little ditties that Sinara needs to make the magic happen
# -----------------------------------------------------------------------
require 'rubygems'

# If you're using bundler, you will need to add this
require 'bundler/setup'

require 'sinatra'
require 'sinatra/partial'
require 'json'
require 'github_api'

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

  def plugins
    {
      "bourbon" => 'bourbon/bourbon',
      "breakpoint" => 'breakpoint',
      "compass" => 'compass',
      "sassy-buttons" => 'sassy-buttons',
      "singularity.gs" => 'singularitygs',
      "stipe" => './sass/stipe',  # This is a local manifest file that @imports all the Stipe modules
      "susy" => 'susy',
    }
  end

  def import_plugin(params)
    Compass.sass_engine_options[:load_paths].each do |path|
      Sass.load_paths << path
    end
    
    if plugins.has_key?(params[:plugin])
      sass = "@import \"#{plugins[params[:plugin]]}\"#{";" if params[:syntax] == 'scss'}\n\n#{params[:sass]}"
    else
      sass = params[:sass]
    end
  end
  
  def compile_sass(params, sass)
    begin
      send("#{params[:syntax]}".to_sym, sass.chomp, {:style => :"#{params[:output]}", :quiet => true})

    rescue Sass::SyntaxError => e
      status 200
      e.to_s
    end    
  end
end


get '/' do
  @plugins = plugins

  erb :index
end


post '/compile' do
  sass = import_plugin(params)

  compile_sass(params, sass)
end


get '/thankyou' do
  erb :thankyou
end


post '/gist' do
  sass = import_plugin(params)
  css = compile_sass(params, sass)
  
  gist = {
    sass: sass, 
    css: css
  }
  
  sass_file = "sass.scss"
  css_file = "css.css"
  
  # gist = {
  #   description: "Gist off",
  #   public: true,
  #   files: {
  #     :sass_file => {
  #       content: "#{sass}"
  #     },
  #     :css_file => {
  #       content: "#{css}"
  #     }
  #   }
  # }
  

  
  
  # gist.to_json
  
  github = Github::Gists.new

  data = github.create(description: "Gist off", public: true, files: {
    :css_file => {
      content: "#{css}"
    },
    :sass_file => {
      content: "#{sass}"
    }    
  })
    
  data.html_url.to_s
end