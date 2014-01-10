require './app'

use Rack::Static, :urls => ["/javascript"]
run Snowdash::App
