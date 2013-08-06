module Sassmeister

  def self.github(auth_token = '')
    github = Github.new do |config|
      config.client_id = gh_config['client_id']
      config.client_secret = gh_config['client_secret']
      config.oauth_token = auth_token
    end
  end

end