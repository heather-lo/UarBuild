#! /usr/bin/env ruby

#require './lib/UarBuild'
require 'UarBuild'
require "pp"

build_version = 'ua-build50'
environment = 'poc'
application_name = 'Kuali Coeus'
update_cc_command = 'update_custom_cookbooks'
deploy_command = 'deploy'


stack_helper = UarBuild::OpsWorksStackHelper.new("us-east-1")
#p stack_helper.describe_current_stacks
stack_settings = stack_helper.get_deploy_info(environment)
#puts "#{environment} stack settings: "
#PP.pp(stack_settings)
#print "\n"
#puts "Available Keys for #{environment} stack:"
#PP.pp(stack_settings.keys)
#print "\n"

stack_helper.update_custom_json(stack_settings, build_version)

#puts "Stack ID: #{stack_settings[:stack_id]}"
#puts "Application Name: #{application_name}"
application_info = stack_helper.get_app_info(stack_settings[:stack_id], application_name)
#print "Application Info: \n"
#PP.pp(application_info)

stack_helper.deploy_app(stack_settings[:stack_id], application_info[0][:app_id], { :name => update_cc_command })
stack_helper.deploy_app(stack_settings[:stack_id], application_info[0][:app_id], { :name => deploy_command })