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


  def get_build_dependencies(sass)
    dependencies = {
      'Sass' =>  Gem.loaded_specs["sass"].version.to_s,
      'Compass' => Gem.loaded_specs["compass"].version.to_s
    }

    get_imports_from_sass(sass) {|name, plugin| dependencies[name] = plugin[:version] }

    return dependencies
  end


  def get_frontmatter_dependencies(sass)
    frontmatter = sass.scan(/^\/\/ ([\w\s]+?) \(v([[:alnum:]\.]+?)\)\s*$/)

    dependencies = {}

    unless frontmatter.empty?
      frontmatter.each {|name, version| dependencies[name] = version}
    end

    return dependencies
  end


  def pack_dependencies(sass, dependencies)
    sass.slice!(/(^\/\/ [\-]{3,4}\n(?:\/\/ .+\n)*\/\/ [\-]{3,4}\s*)*/)
 
    if dependencies.has_key?('libsass')
      frontmatter = "// ----\n// libsass (v#{dependencies.delete('libsass')})\n// ----"

    else
      frontmatter = "// ----\n// Sass (sass-version)\n// Compass (compass-version)\n// ----"

      frontmatter.gsub!(/sass-version/, "v#{dependencies.delete('Sass')}")
      frontmatter.gsub!(/compass-version/, "v#{dependencies.delete('Compass')}")
    end

    dependencies.each {|name, version| frontmatter.gsub!(/\/\/ ----\Z/, "// #{name} (v#{version})\n// ----") }

    return frontmatter
  end


  def unpack_dependencies(sass)
    frontmatter = sass.slice(/^\/\/ ---\n(?:\/\/ .+\n)*\/\/ ---\n/)

    if frontmatter.nil?
      frontmatter = sass.scan(/^\/\/ ([\w\s]+?) [\(\)v[:alnum:]\.]+?\s*$/).first
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


  def sass_compile(sass, syntax, output_style)
    imports = ''

    if ! sass.match(/^\/\/ ----\n/) && sass.match(/^\/\/ ([\w\s]+?) [\(\)v\d\.]+?\s*$/)
      imports = unpack_dependencies(sass)
      imports = imports.join("#{syntax == 'scss' ? ';' : ''}\n") + "#{syntax == 'scss' ? ';' : ''}\n" if ! imports.nil?
    end

    sass.slice!(/(^\/\/ [\-]{3,4}\n(?:\/\/ .+\n)*\/\/ [\-]{3,4}\s*)*/)

    sass = imports + sass if ! imports.nil?

    require_plugins(sass)

    begin
      send("#{syntax}".to_sym, sass.chomp, {:style => :"#{output_style}", :quiet => true})

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
end
