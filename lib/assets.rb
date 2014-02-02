require 'yaml'

module Assets

  HOST = ''

  def javascript_tags(bundle)
    return "<script src=\"#{HOST}/js/#{bundle}.js#{version}\"></script>" if settings.environment == :production

    assets = YAML.load_file("config/assets.yml")

    javascripts = assets['javascripts'][bundle].collect do |js|
      "<script src=\"#{HOST}/#{js.sub('javascripts', 'js')}\"></script>"
    end

    javascripts.join("\n")
  end

  def stylesheet_tags(bundle)
    return "<link rel=\"stylesheet\" href=\"#{HOST}/css/#{bundle}.css#{version}\">" if settings.environment == :production

    "<link rel=\"stylesheet\" href=\"#{HOST}/css/#{bundle}.css\">"
  end

  def version
    if build = (File.read('config/build.txt') rescue false)
      return "?v=#{build}"
    end

    nil
  end
end
