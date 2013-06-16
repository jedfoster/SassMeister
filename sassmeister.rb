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
require 'yaml'

require 'haml'
require 'slim'

set :partial_template_engine, :erb

configure :production do
  require 'newrelic_rpm'

  helpers do
    def github(auth_token = '')
      github = Github.new do |config|
        config.client_id = ENV['GITHUB_ID']
        config.client_secret = ENV['GITHUB_SECRET']
        config.oauth_token = auth_token
      end
    end

    use Rack::Session::Cookie, :key => 'sassmeister.com',
                               :domain => 'sassmeister.com',
                               :path => '/',
                               :expire_after => 7776000, # 90 days, in seconds
                               :secret => ENV['COOKIE_SECRET']
  end
end

configure :development do
  helpers do
    def github(auth_token = '')
      gh_config = YAML.load_file("config/github.yml")

      github = Github.new do |config|
        config.client_id = gh_config['client_id']
        config.client_secret = gh_config['client_secret']
        config.oauth_token = auth_token
      end
    end

    use Rack::Session::Cookie, :key => 'sassmeister.dev',
                               :path => '/',
                               :expire_after => 7776000, # 90 days, in seconds
                               :secret => 'local'
  end
end


helpers do
  include ERB::Util
  alias_method :code, :html_escape

  # From: http://rubyquicktips.com/post/2625525454/random-array-item
  class Array
    def random
      shuffle.first
    end

    def to_sentence
      length < 2 ? first.to_s : "#{self[0..-2] * ', '}, and #{last}"
    end
  end
  
  class String
    def titleize
      split(/(\W)/).map(&:capitalize).join
    end
  end

  def plugins
    YAML.load_file("config/plugins.yml").each do |plugin|
      plugin.last[:version] = Gem.loaded_specs[plugin.last[:gem]].version.to_s
    end
  end

  def import_plugin(params)
    sass = ''

    if plugins.has_key?(params[:plugin])
      require plugins[params[:plugin]][:gem]

      Compass.sass_engine_options[:load_paths].each do |path|
        Sass.load_paths << path
      end

      plugins[params[:plugin]][:import].each do |import|
        sass << "@import \"#{import}\"#{";" if params[:syntax] == 'scss'}\n\n" if ! import.empty?
      end
    end

    sass << params[:sass]
  end

  def sass_compile(params, sass)
    begin
      send("#{params[:syntax]}".to_sym, sass.chomp, {:style => :"#{params[:output]}", :quiet => true})

    rescue Sass::SyntaxError => e
      status 200
      e.to_s
    end
  end

  def sass_convert(from_syntax, to_syntax, sass)
    begin
      ::Sass::Engine.new(sass, {:from => from_syntax.to_sym, :to => to_syntax.to_sym, :syntax => from_syntax.to_sym}).to_tree.send("to_#{to_syntax}").chomp
    rescue Sass::SyntaxError => e
      sass
    end
  end

  def unpack_dependencies(sass)
    frontmatter = sass.slice(/^\/\/ ---\n(?:\/\/ .+\n)*\/\/ ---\n/)

    if frontmatter.nil?
      frontmatter = sass.split(/(^\/\/ | v\d)/)
    else
      frontmatter = frontmatter.to_s.gsub(/(\/\/ |---|\(.+$)/, '').strip.split(/\n/)
    end

    frontmatter.delete_if do |x|
      ! @plugins.key?(x.to_s.titleize.strip)
    end

    frontmatter[0].titleize.strip unless frontmatter.empty?
  end

  def pack_dependencies(params)
    params[:sass].slice!(/(^\/\/ ---\n(?:\/\/ .+\n)*\/\/ ---\s*)*/)

    frontmatter = <<-END.gsub(/^ {6}/, '')
      // ---
      // Sass (version)
      // ---
    END

    frontmatter.gsub!(/version/, "v#{Gem.loaded_specs["sass"].version.to_s}")

    if ! params[:plugin].empty?
      frontmatter.gsub!(/^(\/\/ Sass)/, "// #{params[:plugin]} (v#{plugins[params[:plugin]][:version]})\n\\1")
    end

    return frontmatter
  end
end

before do
  @github = github(session[:github_token])
  @gist_input = ''
end


get '/' do
  @plugins = plugins

  erb :index
end


post '/compile' do  
  if params[:sass]
    sass = import_plugin(params)

    sass_compile(params, sass)
  else
    # HTML
    
    case params[:html_syntax]
    when 'haml'
      return haml params[:html], :suppress_eval => true
    when 'slim'
      # ^(\s*?)((\S+ )?=|==|-)( .*$)
      html = params[:html].gsub(/^(\s*?)((\S+ )?=|==|-)( .*$)/, "\1/ \2\4")

      return html
      return slim html, :pretty => true, :disable_engines => [:ruby, :javascript, :css, :erb, :haml, :sass, :scss, :less, :builder, :liquid, :markdown, :textile, :rdoc, :radius, :markaby, :nokogiri, :coffee]
      
    # when 'markdown'
      
    # when 'textile'      
    
    else
      return params[:html]
    end
  end
end


get '/compile' do
  erb :compiled_html, :layout => false
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


get '/authorize' do
  redirect to @github.authorize_url :scope => ['gist', 'user']
end


get '/authorize/return' do
  token = @github.get_token(params[:code])

  user = github(token.token).users.get

  session[:github_token] = token.token
  session[:github_id] = user.login
  session[:gravatar_id] = user.gravatar_id

  redirect to('/')
end


get '/logout' do
  session[:github_token] = nil
  session[:github_id] = nil
  session[:gravatar_id] = nil

  redirect to('/')
end


get %r{/gist(?:/[\w]*)*/([\d]+)} do
  @plugins = plugins

  begin
    files = @github.gists.get(params[:captures].first).files

    if( ! files["#{files.keys.grep(/.+\.(scss|sass)/)[0]}"])
      syntax = plugin = ''
      sass = "// Sorry, I couldn't find any valid Sass in that Gist."

    else
      sass = files["#{files.keys.grep(/.+\.(scss|sass)/)[0]}"].content

      if files["#{files.keys.grep(/.+\.(scss|sass)/)[0]}"].filename.end_with?("scss")
        syntax = 'scss'
      else
        syntax = 'sass'
      end

      plugin = unpack_dependencies(sass)

      sass.gsub!(/^\s*(@import.*)\s*/, "\n// #{'\1'}\n\n")
    end

  rescue Github::Error::NotFound => e
    status 200

    syntax = plugin = ''
    sass = "// Sorry, that Gist doesn't exist.\n//#{e.to_s.gsub(/(GET|api.|https:\/\/)/, '')}"
  end

  @gist_input = {
    :syntax => syntax,
    :plugin => plugin,
    :sass => sass
  }.to_json

  erb :index
end


post '/gist/?:edit?' do
  dependencies = pack_dependencies(params)

  sass = params[:sass]
  css = sass_compile(params, import_plugin(params))

  description = "Generated by SassMeister.com, the Sass playground."

  sass_file = "SassMeister-input.#{params[:syntax]}"
  css_file = "SassMeister-output.css"

  if params[:edit]
    data = @github.gists.edit(session[:gist], files: {
      css_file => {
        content: "#{css}"
      },
      sass_file => {
        content: "#{dependencies}\n\n#{sass}"
      }
    })
  else
    data = @github.gists.create(description: description, public: true, files: {
      css_file => {
        content: "#{css}"
      },
      sass_file => {
        content: "#{dependencies}\n\n#{sass}"
      }
    })
  end

  session[:gist] = data.id.to_s

  data.id
end


post '/reset' do
  session[:gist] = ''
end