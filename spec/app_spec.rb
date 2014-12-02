require 'json'
require_relative 'spec_helper.rb'

class AppTest < MiniTest::Spec
  include Rack::Test::Methods

  register_spec_type /.+$/, self

  def app
    SassMeisterApp
  end


  describe 'Routes' do
    describe 'GET /' do
      before do
        get '/app/compilers'
      end

      it 'responds with JSON containing the compiler version' do
        json = JSON.parse last_response.body

        last_response.status.must_equal 200
        last_response.header['Content-Type'].must_equal 'application/json'
        
        assert_equal json.first['engine'].strip, 'Ruby'
      end
    end
  end

end

