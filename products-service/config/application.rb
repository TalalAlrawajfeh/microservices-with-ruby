require 'bundler'
Bundler.require
$: << File.expand_path('../', __FILE__)
Dir['./app/**/*.rb'].sort.each { |file| require file }
set :root, Dir['./app']

# to get the ip address of the host in a docker container use IPSocket.getaddress(ENV['HOSTNAME']), or
# require 'socket'
# ip_address = Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address
