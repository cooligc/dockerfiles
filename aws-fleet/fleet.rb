#!/usr/bin/env ruby

require 'json'
require 'aws-sdk'

STDOUT.sync = true

$environment=ARGV[0]
$fleet_command=ARGV[1]
$service=ARGV[2]

$node_prefix="service-node-"

puts "Environment: #{$environment}"
puts "Executing fleet command: #{$fleet_command}"


if not $service.nil? then
  puts "Service: #{$service}"
  $service_file="/services/#{$service}.service"
  if not File.exist?($service_file) then
    abort "Service file #{$service_file} does not exist."
  else
    puts "Running fleet command '#{$fleet_command}'' on service #{$service_file}..."
    $fleet_command="#{$fleet_command} #{$service_file}"
  end
end

Aws.config.update({
  region: 'eu-west-1',
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_KEY']),
})

def service_nodes()
  ec2 = Aws::EC2::Client.new
  puts "Getting cluster instances..."
  pages=ec2.describe_instances
  pages[:reservations].flat_map do |reservation|
    reservation[:instances]
      .select{|instance| instance[:state][:name] == "running"}
      .select{|instance| instance[:tags].any?{|tag| tag[:key] == "Environment" && tag[:value].casecmp($environment) == 0}}
      .select{|instance| instance[:tags].any?{|tag| tag[:key] == "Name" && tag[:value].start_with?($node_prefix)}}
  end
end

$nodes=service_nodes()

if $nodes.empty? then
  abort "No running nodes matching #{$node_prefix}* could be found in environment #{$environment}."
else
  $hostname=$nodes.first[:public_ip_address]
  $tunnel = "#{$hostname}:22"
  puts "Using fleet tunnel: #{$tunnel}"
  $fleet_args="--strict-host-key-checking=false --tunnel=#{$tunnel}"
  cmd="./fleetctl #{$fleet_args} #{$fleet_command}"
  puts %x{#{cmd}}
end
