$LOAD_PATH.unshift(File.join(File.dirname(File.realpath(__FILE__)), 'lib'))

require 'sinatra/base'
require 'sinatra/partial'
require 'sinatra/config_file'
require 'chairman'
require 'json'
require 'yaml'
require 'sassmeister/helpers'
require 'object'
require 'array'
require 'assets'
require 'sassmeister/api_routes'

class SassMeisterEmbeddedApp < Sinatra::Base
  register Sinatra::Partial
  register Sinatra::ConfigFile

  set :partial_template_engine, :erb
  set :protection, except: :frame_options

  config_file 'config/config.yml'

  use SassMeister::ApiRoutes

  helpers SassMeister::Helpers
  helpers Assets

  APP_DOMAIN = settings.app_domain
  SANDBOX_DOMAIN = settings.sandbox_domain
  CACHE_MAX_AGE = settings.cache_max_age
  # Assets::HOST = settings.assets_host
  Assets::HOST = settings.assets_host unless defined? Assets::HOST

  COOKIE_DOMAIN = settings.cookie_domain
  APP_VERSION = settings.app_version
  SESSION_DURATION = settings.session_duration
  Chairman.config ENV['GITHUB_ID'], ENV['GITHUB_SECRET'], ['gist']

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


  get %r{/gist(?:/[\w]*)*/([\d\w]+)} do
    id = params[:captures].first

    begin
      response = @github.gist id

      raise Octokit::NotFound unless response.message.nil?

      # For now, we only return the first .sass or .scss file we find.
      file = response.files["#{response.files._fields.grep(/.+\.(scss|sass)/i)[0]}"]

      if( ! file)
        syntax = filename = owner = ''
        sass = '// Sorry, I couldn\'t find any valid Sass in that Gist.'

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
      gist_id: id,
      owner: owner,
      sass_filename: filename,
      html_filename: (html_filename || ''),
      sass: {
        input: sass,
        syntax: syntax,
        original_syntax: syntax,
        dependencies: get_frontmatter_dependencies(sass)
      },
      html: {
        input: (html || '').gsub('</script>', '<\/script>'),
        syntax: (html_syntax || '').gsub('</script>', '<\/script>')
      }
    }

    @gist_output = {
      css: (css_file || ''),
      html: (rendered_file || '').gsub('</script>', '<\/script>')
    }

    @body_class = 'embedded'

    erb :index
  end

  run! if app_file == $0
end

