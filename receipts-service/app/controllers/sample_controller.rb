require 'sinatra'
require 'json'

# please leave this empty get request for health check or change health check api in config/application.rb
get '/' do
    status 200
    body ''
end
