desc 'Compile the app\'s icons to an SVG sprite'
task 'svg:sprite' do
  require 'nokogiri'

  @doc = Nokogiri::XML::Document.new

  @svg = @doc.add_child Nokogiri::XML::Node.new "svg", @doc

  @svg['xmlns'] = 'http://www.w3.org/2000/svg'
  @svg['hidden'] = true

  Dir.glob('svg/*.svg').each do |file|
    node = Nokogiri::XML(File.open(file)).css('svg').first

    id = file.split('/')[1].split('.')[0]

    symbol = Nokogiri::XML::Node.new "symbol", @doc
    symbol['viewBox'] = node['viewBox']
    symbol['id'] = id
    symbol << "<title>#{id}</title>"
    symbol << node.children.to_xml.strip

    @svg.add_child(symbol)
  end

  File.open("public/img/icons.svg", 'w') {|f| f.write(@doc.to_xml.gsub(/(\n|\t|\s{2,})/, '')) }
end

