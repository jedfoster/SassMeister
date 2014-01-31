require 'yaml'

module Assets

  def javascript_tags
    return "<script src=\"/javascripts/app.js#{version}\"></script>" if settings.environment == :production

    assets = YAML.load_file("config/assets.yml")

    javascripts = assets['javascripts']['app'].collect do |js|
      "<script src=\"#{js.sub('public', '')}\"></script>"
    end

    return javascripts.join("\n")
  end

  def stylesheet_tags
    "<link rel=\"stylesheet\" href=\"/stylesheets/style.css#{version if settings.environment == :production}\">"
  end

  def version
    if build = (File.read('config/build.txt') rescue false)
      return "?v=#{build}"
    end

    nil
  end
end
