
require 'rails/generators/resource_helpers'
require "rails/generators/model_helpers"

module HocUtils
  module Generators
    class ApiScaffoldGenerator < Rails::Generators::NamedBase

      include Rails::Generators::ModelHelpers
      include Rails::Generators::ResourceHelpers

      desc "Generate a model with api controller and optional administration interface and routes for api controller"
      argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"

      class_option :admin, type: :boolean, default: true, desc: "Generate administration interface"
      class_option :routes, type: :boolean, default: true, desc: "Generate routes"
      class_option :api_version, type: :string, default: "v1", desc: "Version of namespace"

      source_root File.expand_path('templates', __dir__)


      def api_version
        options.api_version.downcase
      end

      # Generates the model and the migration. Overrides the model definition to add acts_as_api block
      def generate_model
        say "Generates app/models/#{singular_table_name}.rb", :bold
        invoke :model
        inject_into_class "app/models/#{singular_table_name}.rb", singular_table_name.camelize do
<<-ACTS

  acts_as_api
  api_accessible :basic do |t|
  #{attributes_names.map { |name| "\tt.add :#{name}" }.join("\n")}
    t.add :created_at
    t.add :updated_at
  end

ACTS
        end
      end

      # Scaffolds the api controller
      def generate_api_controller
        say "Generates app/controllers/api/#{api_version}/#{plural_table_name}_controller.rb", :bold
        template "api_controller.rb.tt", "app/controllers/api/#{api_version}/#{plural_table_name}_controller.rb"
      end

      # Generates routes in config/routes.rb. Will namespace resources to api/[api_version].
      def generate_routes
        return unless options.routes?
        say "Generates routes. You may want to merge api/#{api_version} namespaces in config/routes.rb", :bold
        generate "resource_route api/#{api_version.downcase}/#{plural_table_name}"
      end

      # Generates spec stubs for swagger.
      def generate_specs
        say "Generates spec/integration/#{plural_table_name}_spec.rb", :bold
        template "spec.rb.tt", "spec/integration/#{plural_table_name}_spec.rb"
        say "Adds definitions to spec/swagger_helper.rb", :bold
        insert_into_file "spec/swagger_helper.rb", :after => "definitions: {\n" do
          %{
          # AUTO GENERATED STUB TODO: update with correct fields
          #{singular_table_name}_input: {
            description: 'TODO: replace with correct description',
            type: 'object',
            properties: {

            },
            required: [] #TODO require
          },
          # AUTO GENERATED STUB TODO: update with correct fields
          #{singular_table_name}: {
            description: 'TODO: replace with correct description',
            type: 'object',
            properties: {
              id: { type: "integer"},
              created_at: { type: "string"},
              updated_at: { type: "string"},
            }
          },
        }
        end
      end

      # Generates admin controllers in app/admin
      def generate_admin_controllers
        return unless options.admin?
        say "Generates app/admin/#{plural_table_name}_admin.rb", :bold
        generate "trestle:resource #{singular_table_name}"
      end

      def migrate
        rails_command 'db:migrate'
      end
    end
  end
end
