$LOAD_PATH.unshift(File.join(File.dirname(File.realpath(__FILE__)), 'lib'))

require 'sinatra/base'
require 'sinatra/partial'
require 'chairman'
require 'json'
require 'yaml'
require 'sassmeister/helpers'
require 'object'
require 'array'
require 'assets'
require 'sassmeister/client'

class SassMeisterEmbeddedApp < Sinatra::Base
  register Sinatra::Partial

  set :protection, :except => :frame_options

  helpers SassMeister::Helpers
  helpers Assets

  configure do
    APP_VERSION = '2.0.1'
  end

  set :partial_template_engine, :erb

  configure :production do
    APP_DOMAIN = 'sassmeister.com'
    SANDBOX_DOMAIN = 'sandbox.sassmeister.com'
    Assets::HOST = 'http://cdn.sassmeister.com'
    require 'newrelic_rpm'

    Chairman.config(ENV['GITHUB_ID'], ENV['GITHUB_SECRET'], ['gist'])
    CACHE_MAX_AGE = 1800  # 30 mins.

    COMPILER_ENDPOINTS = {
      '3.4' => "http://sassmeister-34.herokuapp.com",
      '3.3' => "http://sassmeister-34.herokuapp.com",
      '3.2' => "http://sassmeister-32.herokuapp.com",
      'lib' => "http://sassmeister-libsass.herokuapp.com"
    }
  end

  configure :development do
    APP_DOMAIN = 'sassmeister.dev'
    SANDBOX_DOMAIN = 'sandbox.sassmeister.dev'
    yml = YAML.load_file("config/github.yml")
    Chairman.config(yml["client_id"], yml["client_secret"], ['gist'])
    CACHE_MAX_AGE = 0

    COMPILER_ENDPOINTS = {
      '3.4' => "http://sass3-4.sassmeister.dev",
      '3.3' => "http://sass3-3.sassmeister.dev",
      '3.2' => "http://sass3-2.sassmeister.dev",
      'lib' => "http://lib.sassmeister.dev"
    }
  end


  before do
    @github = Chairman.session(nil)
    @gist = nil

    params[:syntax].downcase! unless params[:syntax].nil?
    params[:original_syntax].downcase! unless params[:original_syntax].nil?

    cache_control :public, max_age: CACHE_MAX_AGE
  end


  not_found do
    @body_class = 'oops-404'

    return erb :'404' unless @id

    return erb :'gist-404', locals: {id: @id}
  end


  get '/' do
    redirect "http://#{APP_DOMAIN}"
  end


  before '/app/:compiler/*' do
    return erb :'404' unless COMPILER_ENDPOINTS.include? params[:compiler]

    @api = SassMeister::Client.new(COMPILER_ENDPOINTS[params[:compiler]])
  end

  after '/app/*' do
    headers @api.headers
  end

  get '/app/:compiler/extensions' do
    @api.extensions

    return @api.body
  end

  post '/app/:compiler/compile' do
    @api.compile params

    return @api.body
  end

  post '/app/:compiler/convert' do
    if params[:compiler] == 'lib'
      @api = SassMeister::Client.new(COMPILER_ENDPOINTS['3.3'])
    end


    @api.convert params

    return @api.body
  end


  get %r{/gist(?:/[\w]*)*/([\d\w]+)} do
    id = params[:captures].first

    begin
      response = @github.gist(id)

      raise Octokit::NotFound unless response.message.nil?

      # For now, we only return the first .sass or .scss file we find.
      file = response.files["#{response.files._fields.grep(/.+\.(scss|sass)/i)[0]}"]

      if( ! file)
        syntax = filename = owner = ''
        sass = "// Sorry, I couldn't find any valid Sass in that Gist."

      else
        sass = file.content
        filename = file.filename
        owner = (response.respond_to?(:user) ? response.user.login : nil)

        syntax = file.filename.slice(-4, 4)
      end

      html_file = response.files["#{response.files._fields.grep(/.+\.(haml|textile|markdown|md|html)/)[0]}"]

      if(html_file)
        html = html_file.content
        html_filename = html_file.filename

        html_syntax = html_file.filename.split('.').pop
        html_syntax = 'markdown' if html_syntax == 'md'

        html_syntax.capitalize!
      end

      if css_file = response.files["#{response.files._fields.grep(/.+-output\.css/)[0]}"]
        css_file = css_file.content.to_s
      end

      if rendered_file = response.files["#{response.files._fields.grep(/.+-rendered\.html/)[0]}"]
        rendered_file = response.files["#{response.files._fields.grep(/.+-rendered\.html/)[0]}"].content.to_s
      end

    rescue Octokit::NotFound => e
      @id = id
      status 404

      return
    end

    last_modified response.updated_at.httpdate

    @gist = {
      :gist_id => id,
      :gist_owner => owner,
      :sass_filename => filename,
      :html_filename => (html_filename || ''),
      :sass => {
        :input => sass,
        :syntax => syntax,
        :original_syntax => syntax,
        :dependencies => get_frontmatter_dependencies(sass)
      },
      :html => {
        :input => (html || '').gsub('</script>', '<\/script>'),
        :syntax => (html_syntax || '').gsub('</script>', '<\/script>')
      }
    }

    @gist_output = {
      :css => (css_file || ''),
      :html => (rendered_file || '').gsub('</script>', '<\/script>')
    }

    @body_class = 'embedded'

    erb :index
  end

  run! if app_file == $0
end
