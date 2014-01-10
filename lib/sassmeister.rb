module SassMeister

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

end
