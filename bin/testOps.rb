#! /usr/bin/env ruby

#require './lib/UarBuild'
require 'UarBuild'

build_version = 'ua-build1'

#UarBuild::OpsWorksStackHelper.new.describe_current_stacks

#p UarBuild::OpsWorksStackHelper.new.get_deploy_info("dev")

stack_helper = UarBuild::OpsWorksStackHelper.new("us-east-1")
#p stack_helper.describe_current_stacks
stack_settings = stack_helper.get_deploy_info("poc")
stack_helper.update_custom_json(stack_settings, build_version)