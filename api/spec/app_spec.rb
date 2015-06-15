require 'json'
require_relative 'spec_helper.rb'
require 'fakeredis'
require 'sassmeister/redis'

class AppTest < MiniTest::Spec
  include Rack::Test::Methods

  register_spec_type /.+$/, self

  def app
    SassMeisterApp.new
  end

  describe 'Compiler menu' do
    before do
      compilers = {
        test1: {
          sass: '1.2.3',
          engine: 'Ruby'
        },
        lib: {
          sass: '5.4.3',
          engine: 'Ruby'
        }
      }

      @metastore = SassMeister::Redis.new 'compilers'
      @metastore.set compilers
    end

    it 'builds the compiler menu from the Redis cache' do
      assert_equal app.helpers.compiler_menu.strip, '<select name="version" class="fancy_dropdown">
  <option value="test1">1.2.3</option>
  <option value="lib">LibSass 5.4.3</option>
</select>'
    end
  end

  describe 'Extensions info list' do
    before do
      extensions = {
        Ark: {
          version: '1.2.3',
          import: [
            'ark/ark'
          ],
          homepage: 'https://github.com/drewbolles/ark'
        },
        Bitters: {
          version: '4.5.6',
          import: [
            'bourbon/bourbon',
            'neat/neat',
            'bitters/bitters'
          ],
          homepage: 'https://github.com/jedfoster/bitters-compass'
        }
      }

      @metastore = SassMeister::Redis.new 'extensions'
      @metastore.set extensions
    end

    it 'builds the extension info list from the Redis cache' do
      assert_equal app.helpers.extension_info_list.strip, '<ol>
  <li><a href="https://github.com/drewbolles/ark">Ark</a></li>
  <li><a href="https://github.com/jedfoster/bitters-compass">Bitters</a></li>
</ol>'

    end
  end

end

