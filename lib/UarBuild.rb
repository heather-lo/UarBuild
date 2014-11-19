require "./lib/UarBuild/version"
require "aws-sdk"
require "json"
require "pp"

module UarBuild
  class OpsWorksStackHelper

    def initialize(desired_region)
      #desired_region || = 'us-east-1'
      #@options = {:region => desired_region}
      @options = {:region => 'us-east-1'}
      @opworks_client = AWS::OpsWorks::Client.new(@options)
  	end

    def describe_current_stacks
      response = @opworks_client.describe_stacks
      #PP.pp(response.data)
      response.data
    end

    def get_deploy_info(environment)
      all_data = describe_current_stacks[:stacks]
      env_stack = all_data.select { |s| s[:name].downcase.start_with?("uar " + environment) }
      #PP.pp(env_stack)
      env_stack.fetch(0)
    end

    def update_custom_json(stack_settings, build_version)
      p "New Build Version: " + build_version
      print "\n"

      stack_id = stack_settings.fetch(:stack_id)
      custom_json_string = stack_settings.fetch(:custom_json)
      p "Custom JSON String:"
      p custom_json_string
      print "\n"
      
      custom_json = JSON.parse(custom_json_string)
      #p "Current build version"
      #p custom_json['deploy']['kc']['local_version']
      custom_json['deploy']['kc']['local_version'] = build_version
      #p "New build version"
      #p custom_json['deploy']['kc']['local_version']
      p "Custom JSON"
      p custom_json
      print "\n"
      
      updated_custom_json = JSON.pretty_generate(custom_json, opts = {:space_before => '\n\t'})
      p "Formatted and updated custom JSON: "
      p updated_custom_json
      print "\n"
      
      stack_settings[:custom_json] = updated_custom_json
      p "Updated stack settings: "
      p stack_settings

      updated_stack_settings = { :stack_id => stack_id, :custom_json => updated_custom_json }

      @opworks_client.update_stack(updated_stack_settings)
    end

    def get_app_info(stack_id, app_name)
      puts "Desired Stack ID: #{stack_id}"
      puts "Desired Application Name: #{app_name}"
      apps_in_stack = @opworks_client.describe_apps({:stack_id => stack_id})
      #PP.pp(apps_in_stack[:apps][0][:app_id])

      desired_app = apps_in_stack[:apps].select { |a| a[:name] == app_name }
      #PP.pp(desired_app)
      raise "Unexpected number of apps!" if desired_app.length != 1

      desired_app
    end

    def deploy_app(stack_id, app_id, command)
      @opworks_client.create_deployment( { :stack_id => stack_id, :app_id => app_id, :command => command })
    end
  end
end
