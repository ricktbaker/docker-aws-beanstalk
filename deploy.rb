#!/usr/bin/env ruby

require 'rubygems'

## AWS Credentials
AWS_REGION ='us-east-1';
AWS_KEY = "aws_access_key_id"
AWS_SEC = "aws_secret_access_key"
BEANSTALK_APP = "test-app"
VERSION_LABEL_BASE = "deploy"

begin
  require 'aws-sdk'
rescue LoadError
  puts "You need to have the ruby aws-sdk gem installed"
  puts "gem install aws-sdk"
end

# Check if we're logged in to docker
loggedIn = ''
File.open "#{Dir.home}/.docker/config.json" do |file|
  loggedIn = file.find { |line| line =~ /docker/ }
end

if !loggedIn
  puts "You need to login to dockerhub (docker login)"
  abort
end

puts "Pulling Master..."

puts(`git checkout master`)
puts(`git fetch`)
puts(`git pull --no-edit origin master`)

puts "Bulding docker image"
puts(`docker build -t ricktbaker/node_beanstalk:latest .`)
puts  "Pushing php image to docker hub"
puts(`docker push ricktbaker/node_beanstalk:latest`)

puts "Ready to trigger deployment in beanstalk..."


Aws.config.update({
  region: AWS_REGION,
  credentials: Aws::Credentials.new(AWS_KEY,AWS_SEC)
})

client = Aws::ElasticBeanstalk::Client.new(region: AWS_REGION)

resp = client.update_environment({
  environment_name: BEANSTALK_APP,
  version_label: "deploy"
})

puts resp.to_h[:status]

# Check to see when deploy is finished
$status = 0
until $status == 'Ready' do
  resp = client.describe_environments({
    environment_names: [BEANSTALK_APP]
  })

  data = resp.to_h[:environments]
  $status = data[0][:status]
  puts $status
  if $status != 'Ready'
    sleep(5)
  end
end


