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
      p "Build Version: " + build_version
      print "\n"
      p "Stack Settings:"
      p stack_settings
      print "\n"
      #p "Available Keys:"
      #PP.pp(stack_settings.keys)
      #p "Custom JSON:"
      stack_id = stack_settings.fetch(:stack_id)
      custom_json_string = stack_settings.fetch(:custom_json)
      p "Custom JSON String:"
      p custom_json_string
      print "\n"
      custom_json = JSON.parse(custom_json_string)
      #p custom_json['deploy']['kc']['local_version']
      custom_json['deploy']['kc']['local_version'] = build_version
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
  end
end
