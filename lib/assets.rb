require 'yaml'

module Assets

  HOST = ''

  def javascript_tags(bundle)
    return "<script src=\"#{HOST}/js/#{bundle}#{version(bundle)}.js\"></script>" if settings.environment == :production

    assets = YAML.load_file("config/assets.yml")

    javascripts = assets['javascripts'][bundle].collect do |js|
      "<script src=\"#{HOST}/#{js.sub('javascripts', 'js')}\"></script>"
    end

    javascripts.join("\n")
  end

  def stylesheet_tags(bundle)
    return "<link rel=\"stylesheet\" href=\"#{HOST}/css/#{bundle}#{version(bundle)}.css\">" if settings.environment == :production

    "<link rel=\"stylesheet\" href=\"#{HOST}/css/#{bundle}.css\">"
  end

  def version(bundle)
    if build = (File.read("config/#{bundle}.txt") rescue false)
      return "-#{build}"
    end

    nil
  end
end
