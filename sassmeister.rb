$LOAD_PATH.unshift(File.join(File.dirname(File.realpath(__FILE__)), 'lib'))

require 'rubygems'

# If you're using bundler, you will need to add this
require 'bundler/setup'

require 'sinatra/base'
require 'sinatra/partial'
require 'github_api'
require 'chairman'
require 'json'

require 'sass'
require 'compass'
require 'yaml'

require 'sassmeister'
require 'array'

require 'html/pipeline'
require 'RedCloth'
require 'haml'

require './lib/html/pipeline/haml.rb'

class SassMeisterApp < Sinatra::Base
  register Sinatra::Partial

  # HTML::Pipeline::SanitizationFilter::WHITELIST[:attributes][:all].merge ['class', 'style']

  use Chairman::Routes

  helpers SassMeister

  # implement redirects
  class Chairman::Routes
    configure :production do
      helpers do
        use Rack::Session::Cookie, :key => 'sassmeister.com',
                                   :domain => 'sassmeister.com',
                                   :path => '/',
                                   :expire_after => 7776000, # 90 days, in seconds
                                   :secret => ENV['COOKIE_SECRET']
       end
    end

    configure :development do
      helpers do
        use Rack::Session::Cookie, :key => 'sassmeister.dev',
                                   :path => '/',
                                   :expire_after => 7776000, # 90 days, in seconds
                                   :secret => 'local'
      end
    end
    
    after '/authorize/return' do  
      redirect to('/')
    end

    after '/logout' do
      redirect to('/')
    end
  end

  set :partial_template_engine, :erb

  configure :production do
    require 'newrelic_rpm'

    Chairman.config(ENV['GITHUB_ID'], ENV['GITHUB_SECRET'], ['gist', 'user'])
  end

  configure :development do
    yml = YAML.load_file("config/github.yml")
    Chairman.config(yml["client_id"], yml["client_secret"], ['gist', 'user'])
  end


  before do
    @github = Chairman.session(session[:github_token])
    @gist = nil
    @plugins = plugins
    
    params[:syntax].downcase! unless params[:syntax].nil?
    params[:original_syntax].downcase! unless params[:original_syntax].nil?
    params[:html_syntax].downcase! unless params[:html_syntax].nil?
  end

  get '/' do
    if ! params.keys.grep(/(extension|syntax|output)/).empty?
      extension = params[:extension].split(',') || []
      syntax = (params[:syntax].downcase rescue 'scss')
      output = (params[:output].downcase rescue 'expanded')
      sass = ''

      plugins.each do |key, plugin|
        if ! extension.grep(/#{plugin[:fingerprint].gsub(/\*/, '.*?')}/i).empty?
          require plugin[:gem]

          imports = []
          plugin[:import].each do |import|
            imports << "@import \"#{import}\""
          end

          sass += imports.join("#{syntax == 'scss' ? ';' : ''}\n") + "#{syntax == 'scss' ? ';' : ''}\n" unless imports.nil?
        end
      end

      @gist = {
        :sass => sass,
        :syntax => syntax,
        :output => output
      }.to_json
    end

    erb :index
  end


  post '/compile' do
    if params[:sass]
      sass_compile(params)
    else
      # HTML

      case params[:html_syntax]
      when 'haml'
          return render_html(params[:html], 'Haml')

      when 'markdown'
          return render_html(params[:html], 'Markdown')

      when 'textile'
          return render_html(params[:html], 'Textile')

      else
        return params[:html]
      end
    end
  end


  post '/convert' do
    if params[:sass]
      sass_convert(params[:original_syntax], params[:syntax], params[:sass])
    else
      # HTML
      erb :compiled_html, :layout => false
    end
  end


  get '/thankyou' do
    erb :thankyou
  end


  get '/about' do
    erb :about
  end


  get %r{/gist(?:/[\w]*)*/([\d]+)} do
    id = params[:captures].first

    begin
      response = Github::Gists.new.get(id, client_id: Chairman.client_id, client_secret: Chairman.client_secret)

      # For now, we only return the first .sass or .scss file we find.
      file = response.files["#{response.files.keys.grep(/.+\.(scss|sass)/)[0]}"]

      if( ! file)
        syntax = filename = owner = ''
        sass = "// Sorry, I couldn't find any valid Sass in that Gist."

      else      
        sass = file.content
        filename = file.filename
        owner = (response.respond_to?(:owner) ? response.owner.login : '')
  
        syntax = file.filename.slice(-4, 4)
      end

    rescue Github::Error::NotFound => e
      status 404

      syntax = plugin = ''
      sass = "// Sorry, that Gist doesn't exist.\n//#{e.to_s.gsub(/(GET|api.|https:\/\/)/, '')}"
    end

    @gist = {
      :gist_id => id,
      :gist_filename => filename,
      :gist_owner => owner,
      :can_update_gist => (owner == session[:github_id]),
      :syntax => syntax,
      :sass => sass
    }.to_json

    erb :index
  end


  post '/gist/create' do
    sass = params[:sass]

    dependencies = pack_dependencies(sass)

    css = sass_compile(params)

    description = "Generated by SassMeister.com."

    sass_file = "SassMeister-input.#{params[:syntax]}"
    css_file = "SassMeister-output.css"

    data = @github.gists.create(description: description, public: true, files: {
      css_file => {
        content: "#{css}"
      },
      sass_file => {
        content: "#{dependencies}\n\n#{sass}"
      }
    })  

    content_type 'application/json'

    {
      id: data.id,
      filename: sass_file
    }.to_json.to_s
  end


  post %r{/gist(?:/[\w]*)*/([\d]+)/edit} do
    id = params[:captures].shift

    sass = params[:sass]

    dependencies = pack_dependencies(sass)

    css = sass_compile(params)

    if params[:gist_filename].slice(-4, 4) == params[:syntax]
      sass_file = params[:gist_filename]
      deleted_files = {}
    else
      sass_file = "#{params[:gist_filename].slice(0..-5)}#{params[:syntax]}"
      deleted_files = {params[:gist_filename] => {content: nil}}
    end

    css_file = "SassMeister-output.css"

    data = @github.gists.edit(id, files: {
      css_file => {
        content: "#{css}"
      },
      sass_file => {
        content: "#{dependencies}\n\n#{sass}"
      }
    }.merge(deleted_files))

    content_type 'application/json'

    {
      id: data.id,
      filename: sass_file
    }.to_json.to_s
  end

  post %r{/gist(?:/[\w]*)*/([\d]+)/fork} do
    id = params[:captures].shift

    data = @github.gists.fork(id)

    content_type 'application/json'

    {
      id: data.id
    }.to_json.to_s
  end

  run! if app_file == $0
end
