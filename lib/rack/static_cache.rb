module Rack
  class StaticCache
    def call(env)
      path = env["PATH_INFO"]
      url = @urls.detect{ |u| path.index(u) == 0 }
      unless url.nil?
        path.sub!(/-[\d.]+([.][a-zA-Z][\w]+)?$/, '\1') if @versioning_enabled
        status, headers, body = @file_server.call(env)
        if @no_cache[url].nil?
          headers['Cache-Control'] ="public, max-age=#{@duration_in_seconds}"
          headers['Expires'] = @duration_in_words
          headers.delete 'Etag'
          headers.delete 'Pragma'
          # headers.delete 'Last-Modified'
        end
        [status, headers, body]
      else
        @app.call(env)
      end
    end

    def duration_in_seconds
      (60 * 60 * 24 * @cache_duration).floor
    end
  end
end