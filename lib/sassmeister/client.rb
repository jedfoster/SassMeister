require 'faraday'

module SassMeister
  class Client
    attr_accessor :headers, :body

    def initialize(host, params = {})
      @api_client = Faraday.new(:url => host)
      @params = params
      @headers = {}
      @body = ''
    end

    def extensions
      get '/extensions'
    end

    def compile
      post '/compile', @params
    end

    def convert
      post '/convert', @params
    end

    private
      
      def passthrough_headers
        [
          'content-type', 
          'last-modified', 
          'cache-control'
        ]
      end

      def get(path, params = {})
        call @api_client.get(path, params)
      end

      def post(path, params = {})
        call @api_client.post(path, params)
      end

      def call(api_response)
        api_response.headers.each do |key, value|
          if passthrough_headers.include? key
            @headers[key] = value
          end
        end
  
        @body = api_response.body
        
        return api_response.status
      end
  end
end

