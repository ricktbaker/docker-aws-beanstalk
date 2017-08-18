#!/usr/bin/env ruby

require 'rubygems'

## AWS Credentials
AWS_REGION ='us-east-1';
AWS_KEY = "AKIAI4HJSLNZ7MIGMYMQ"
AWS_SEC = "5bsLwokxdGyAdYnIrRamXgL4j4mrJVj0tmZczHlF"
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





