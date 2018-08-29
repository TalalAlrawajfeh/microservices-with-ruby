require 'bundler'

Bundler.require

require 'socket'
require 'rest-client'

$: << File.expand_path('../', __FILE__)
Dir['./app/**/*.rb'].sort.each { |file| require file }
set :root, Dir['./app']

consul_nodes = JSON.parse(RestClient.get(ENV['CONSUL_URL'] + '/v1/catalog/nodes'))
node = consul_nodes.sample
ip_address = Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address

request = {
  'Service' => {
    'Service' => 'products-service',
    'Address' => ip_address,
    'Port' => ENV['SINATRA_PORT'].to_i
  },
  'Check' => {
    "Node" => node['Node'],
    'CheckID' => 'service:products-service',
    'Name' => 'Products Service health check',
    'Status' => 'passing',
    'ServiceID' => 'products-service',
    'Definition' => {
      'TCP' => ip_address + ':' + ENV['SINATRA_PORT'],
      'Interval'=> '5s',
      'Timeout' => '1s',
      'DeregisterCriticalServiceAfter' => '30s'
    }
  },
  'SkipNodeUpdate'=> false
}.merge(node)

request.delete('Meta')
request.delete('CreateIndex')
request.delete('ModifyIndex')


puts '#############################################'
puts request.to_json
puts ''
puts ENV['CONSUL_URL'] + '/v1/catalog/register'
puts '#############################################'
RestClient.put(ENV['CONSUL_URL'] + '/v1/catalog/register', request.to_json, :content_type => 'application/json')

# to get the ip address of the host in a docker container use IPSocket.getaddress(ENV['HOSTNAME']), or
# require 'socket'
# ip_address = Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address
