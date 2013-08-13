require './sassmeister'

# Gzip responses
use Rack::Deflater

# Run the application
run SassMeisterApp