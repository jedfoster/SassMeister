require 'yaml'

module Assets

  def javascript_tags
    return '<script src="/javascripts/app.js"></script>' if settings.environment == :production

    assets = YAML.load_file("config/assets.yml")

    javascripts = assets['javascripts']['app'].collect do |js| 
      "<script src=\"#{js.sub('public', '')}\"></script>"
    end
  
    return javascripts.join("\n")
  end
end
