#!/usr/bin/env ruby

require 'json'
require 'aws-sdk'

STDOUT.sync = true

$environment=ARGV[0]
$fleet_action=ARGV[1]
$service=ARGV[2]

$node_prefix="service-node-"

puts "Environment: #{$environment}"
puts "Executing fleet command: #{$fleet_action}"

if not $service.nil? then
  if $service == 'all' then
    puts "Service: ALL SERVICES"
  else
    puts "Service: #{$service}"
    $service_file="/services/#{$service}.service"
    if not File.exist?($service_file) then
      abort "Service file #{$service_file} does not exist."
    else
      puts "Running fleet command '#{$fleet_action}' on service #{$service_file}..."
    end
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

def get_fleet_args()
  nodes=service_nodes()
  if nodes.empty?
    abort "No running nodes matching #{$node_prefix}* could be found in environment #{$environment}."
  end
  hostname=nodes.first[:public_ip_address]
  tunnel = "#{hostname}:22"
  return "--strict-host-key-checking=false --tunnel=#{tunnel}"
end


def call_fleet(fleet_action, service_file, fleet_args)
  fleet_cmd="#{fleet_action} #{service_file}"
  cmd="./fleetctl #{fleet_args} #{fleet_cmd}"
  puts "#{fleet_cmd}"
  puts %x{#{cmd}}
end

fleet_args = get_fleet_args()
puts "Using fleet args: #{fleet_args}"

if($service=='all') then
  Dir.foreach('/services') do |file|
    next if file == '.' or file == '..' or not file.end_with? '.service'
    call_fleet($fleet_action, "/services/#{file}", fleet_args)
  end
else
  call_fleet($fleet_action, "/services/#{$service}.service", fleet_args)
end
