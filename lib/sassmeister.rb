module SassMeister
  def plugins
    YAML.load_file("config/plugins.yml").each do |plugin|
      plugin.last[:version] = Gem.loaded_specs[plugin.last[:gem]].version.to_s
    end
  end


  def require_plugins(sass)
    get_imports_from_sass(sass) { |name, plugin| require plugin[:gem] }

    Compass.sass_engine_options[:load_paths].each do |path|
      Sass.load_paths << path
    end
  end


  def get_imports_from_sass(sass)
    imports = sass.scan(/^\s*@import[\s\"\']*(.+?)[\"\';]*$/)
    imports.map! {|i| i.first}

    plugins.each do |key, plugin|
      if ! imports.grep(/#{plugin[:fingerprint].gsub(/\*/, '.*?')}/).empty?
        yield key, plugin if block_given?
      end
    end
  end


  def pack_dependencies(sass)
    sass.slice!(/(^\/\/ [\-]{3,4}\n(?:\/\/ .+\n)*\/\/ [\-]{3,4}\s*)*/)

    frontmatter = "// ----\n// Sass (sass-version)\n// Compass (compass-version)\n// ----"

    get_imports_from_sass(sass) {|name, plugin| frontmatter.gsub!(/\/\/ ----\n\Z/, "// #{name} (v#{plugin[:version]})\n// ----\n") }

    frontmatter.gsub!(/sass-version/, "v#{Gem.loaded_specs["sass"].version.to_s}")
    frontmatter.gsub!(/compass-version/, "v#{Gem.loaded_specs["compass"].version.to_s}")

    return frontmatter
  end


  def unpack_dependencies(sass)
    frontmatter = sass.slice(/^\/\/ ---\n(?:\/\/ .+\n)*\/\/ ---\n/)

    if frontmatter.nil?
      frontmatter = sass.scan(/^\/\/ ([\w\s]+?) [\(\)v\d\.]+?\s*$/).first
    else
      frontmatter = frontmatter.to_s.gsub(/(\/\/ |---|\(.+$)/, '').strip.split(/\n/)
    end

    frontmatter.delete_if do |x|
      ! plugins.key?(x.to_s.strip)
    end

    if frontmatter.empty?
      return nil
    else
      imports = []

      plugins[frontmatter.first.strip][:import].each do |import|
        imports << "@import \"#{import}\""
      end

      return imports
    end
  end


  def sass_compile(params)
    imports = ''

    if ! params[:sass].match(/^\/\/ ----\n/) && params[:sass].match(/^\/\/ ([\w\s]+?) [\(\)v\d\.]+?\s*$/)
      imports = unpack_dependencies(params[:sass])
      imports = imports.join("#{params[:syntax] == 'scss' ? ';' : ''}\n") + "#{params[:syntax] == 'scss' ? ';' : ''}\n" if ! imports.nil?
    end

    params[:sass].slice!(/(^\/\/ [\-]{3,4}\n(?:\/\/ .+\n)*\/\/ [\-]{3,4}\s*)*/)

    params[:sass] = imports + params[:sass] if ! imports.nil?

    require_plugins(params[:sass])

    begin
      send("#{params[:syntax]}".to_sym, params[:sass].chomp, {:style => :"#{params[:output]}", :quiet => true})

    rescue Sass::SyntaxError => e
      status 200
      e.to_s
    end
  end


  def sass_convert(from_syntax, to_syntax, sass)
    begin
      ::Sass::Engine.new(sass, {:from => from_syntax.to_sym, :to => to_syntax.to_sym, :syntax => from_syntax.to_sym}).to_tree.send("to_#{to_syntax}").chomp
    rescue Sass::SyntaxError => e
      sass
    end
  end

  
  def render_html(html, filter)
    context = {
      :gfm => true,
      :whitelist => HTML::Pipeline::SanitizationFilter::WHITELIST
    }

    if filter == 'Textile'
      filter = HTML::Pipeline::TextileFilter

    elsif filter == 'Haml'
      filter = HTML::Pipeline::HamlFilter

    else
      filter = HTML::Pipeline::MarkdownFilter
    end

    pipe = HTML::Pipeline.new [
      filter

    ], context

    pipe.call(html)[:output]
  end
end