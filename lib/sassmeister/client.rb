require 'faraday'
require 'sawyer'

module SassMeister
  class Client
    attr_accessor :headers, :body

    def initialize(host)
      @api_client = Sawyer::Agent.new(host, {serializer: Sawyer::Serializer.yajl}) do |http|
        http.headers['content-type'] = 'application/json'
      end

      @headers = {}
      @body = ''
    end

    def extensions
      get '/extensions'
    end

    def compile(params)
      post '/compile', params
    end

    def convert(params)
      post '/convert', params
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
        call @api_client.call :get, path, params
      end

      def post(path, params = {})
        call @api_client.call :post, path, params
      end

      def call(api_response)
        api_response.headers.each do |key, value|
          if passthrough_headers.include? key
            @headers[key] = value
          end
        end

        if api_response.data.respond_to? :to_hash
          @body = api_response.data.to_attrs.to_json
        else
          @body = api_response.data
        end

        return api_response.status
      end
  end
end

