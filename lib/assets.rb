require 'yaml'

module Assets

  HOST = ''

  def javascript_tags(bundle)
    return "<script src=\"#{HOST}/js/#{bundle}#{version(bundle)}.js\"></script>" if settings.environment == :production

    javascripts = assets['javascripts'][bundle].collect do |js|
      "<script src=\"#{HOST}/#{js.sub('javascripts', 'js')}\"></script>"
    end

    javascripts.join("\n")
  end

  def stylesheet_tags(bundle)
    return "<link rel=\"stylesheet\" href=\"#{HOST}/css/#{bundle}#{version(bundle)}.css\">" if settings.environment == :production

    "<link rel=\"stylesheet\" href=\"#{HOST}/css/#{bundle}.css\">"
  end
  
  def image_tag(image)
    "<img src=\"#{HOST}/images/#{image}\">"
  end

  def version(bundle)
    build = manifest[bundle] || false

    return "-#{build}" if build

    nil
  end

  private

    def assets
      @assets ||= YAML.load_file("config/assets.yml")
    end

    def manifest
      @manifest ||= YAML.load_file('config/asset-manifest.yml')
    end
end
