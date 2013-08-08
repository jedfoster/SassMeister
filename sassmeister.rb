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

require './lib/sassmeister.rb'

set :partial_template_engine, :erb

configure :production do
  require 'newrelic_rpm'

  helpers do

    module Sassmeister
      def self.gh_config
        {
          "client_id" => ENV['GITHUB_ID'],
          "client_secret" => ENV['GITHUB_SECRET']
        }
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

    module Sassmeister
      def self.gh_config
        YAML.load_file("config/github.yml")
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

  include Sassmeister

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

  def require_plugins(sass)
    get_imports_from_sass(sass) { |name, plugin| require plugin[:gem] }

    Compass.sass_engine_options[:load_paths].each do |path|
      Sass.load_paths << path
    end
  end

  def sass_compile(params)
    imports = ''

    if ! params[:sass].match(/^\/\/ ----\n/) && params[:sass].match(/^\/\/ ([\w\s]+?) [\(\)v\d\.]+?\s*$/)
      imports = unpack_dependencies(params[:sass])
      imports = imports.join("#{params[:syntax] == 'scss' ? ';' : ''}\n") + "#{params[:syntax] == 'scss' ? ';' : ''}\n" if ! imports.nil?
    end

    params[:sass].slice!(/(^\/\/ [\-]{3,4}\n(?:\/\/ .+\n)*\/\/ [\-]{3,4}\s*)*/)

    params[:sass] = imports + params[:sass] if ! imports.nil?

    require_plugins(params[:sass])

    begin
      send("#{params[:syntax]}".to_sym, params[:sass].chomp, {:style => :"#{params[:output]}", :quiet => true})

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
      frontmatter = sass.scan(/^\/\/ ([\w\s]+?) [\(\)v\d\.]+?\s*$/).first
    else
      frontmatter = frontmatter.to_s.gsub(/(\/\/ |---|\(.+$)/, '').strip.split(/\n/)
    end

    frontmatter.delete_if do |x|
      ! plugins.key?(x.to_s.titleize.strip)
    end

    if frontmatter.empty?
      return nil
    else
      imports = []
    
      plugins[frontmatter.first.strip][:import].each do |import|
        imports << "@import \"#{import}\""
      end
      
      return imports
    end
  end

  def get_imports_from_sass(sass)
    imports = sass.scan(/^\s*@import[\s\"\']*(.+?)[\"\';]*$/)
    imports.map! {|i| i.first}

    plugins.each do |key, plugin|
      if ! imports.grep(/#{plugin[:fingerprint].gsub(/\*/, '.*?')}/).empty?
        yield key, plugin if block_given?
      end
    end
  end

  def pack_dependencies(sass)
    sass.slice!(/(^\/\/ [\-]{3,4}\n(?:\/\/ .+\n)*\/\/ [\-]{3,4}\s*)*/)

    frontmatter = <<-END.gsub(/^ {6}/, '')
      // ----
      // Sass (sass-version)
      // Compass (compass-version)
      // ----
    END

    get_imports_from_sass(sass) {|name, plugin| frontmatter.gsub!(/\/\/ ----\n\Z/, "// #{name} (v#{plugin[:version]})\n// ----\n") }

    frontmatter.gsub!(/sass-version/, "v#{Gem.loaded_specs["sass"].version.to_s}")
    frontmatter.gsub!(/compass-version/, "v#{Gem.loaded_specs["compass"].version.to_s}")

    return frontmatter
  end
end

before do
  @github = Sassmeister.github(session[:github_token])
  @gist = nil
  @plugins = plugins
end


get '/' do

  erb :index
end


post '/compile' do
  if params[:sass]
    sass_compile(params)
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

  user = Sassmeister.github(token.token).users.get

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
  id = params[:captures].first

  begin
    response = Github::Gists.new.get(id, client_id: Sassmeister.gh_config['client_id'], client_secret: Sassmeister.gh_config['client_secret'])

    # For now, we only return the first .sass or .scss file we find.
    file = response.files["#{response.files.keys.grep(/.+\.(scss|sass)/)[0]}"]

    if( ! file)
      syntax = filename = owner = ''
      sass = "// Sorry, I couldn't find any valid Sass in that Gist."

    else      
      sass = file.content
      filename = file.filename
      owner = response.owner.login
      
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


post %r{/gist(?:/[\w]*)*/([\d]+)/(edit|fork)} do
  id = params[:captures].shift
  action = params[:captures].shift

  sass = params[:sass]
  
  dependencies = pack_dependencies(sass)

  css = sass_compile(params)

  description = "Generated by SassMeister.com, the Sass playground."

  sass_file = "SassMeister-input.#{params[:syntax]}"
  css_file = "SassMeister-output.css"

  case action
  when 'edit'
    data = @github.gists.edit(id, files: {
      css_file => {
        content: "#{css}"
      },
      sass_file => {
        content: "#{dependencies}\n\n#{sass}"
      }
    })

  when 'fork' # Hardcore forking action
    data = @github.gists.fork(id)

  end

  session[:gist] = data.id.to_s

  data.id
end

post '/gist/create' do
  sass = params[:sass]
  
  dependencies = pack_dependencies(sass)

  css = sass_compile(params)

  description = "Generated by SassMeister.com, the Sass playground."

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

  session[:gist] = data.id.to_s

  data.id
end


post '/reset' do
  session[:gist] = ''
end
