
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
      class_option :nested_to, type: :string, default: nil, desc: "Should be nested in"
      source_root File.expand_path('templates', __dir__)

      def is_nested?
        !options.nested_to.nil?
      end

      def singular_parent_name
        options.nested_to.try(:downcase)
      end

      def plural_parent_name
        options.nested_to.try(:pluralize)
      end

      def parent_class_name
        singular_parent_name.try(:classify)
      end

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
        if is_nested?
          template "nested_api_controller.rb.tt", "app/controllers/api/#{api_version}/#{plural_table_name}_controller.rb"
        else
          template "api_controller.rb.tt", "app/controllers/api/#{api_version}/#{plural_table_name}_controller.rb"
        end
      end

      # Generates routes in config/routes.rb. Will namespace resources to api/[api_version].
      def generate_routes
        return unless options.routes?

        if is_nested?
          say "Sorry you have to generate the route manually. because I don't know how to do it when the resource is nested!", :yellow, :bold
          return
        end
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
          # AUTO GENERATED STUB TODO: update with correct fields
          #{plural_table_name}: {
            type: 'object',
            properties: {
              meta: { "$ref": "#/definitions/meta" },
              #{plural_table_name}: { type: 'array', items: { "$ref": "#/definitions/#{singular_table_name}" },},
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
        say "Migrating...", :bold
        rails_command 'db:migrate'
      end

      def update_swagger
        say "Updating swagger documentation...", :bold
        rails_command 'rswag:specs:swaggerize'
      end

      def salute
        say("Generation complete.", :green, :bold)
        say("Next step is to customize the generated code.", :green)
        say("* Open 'spec/swagger_helper.rb' and change the definitions #{singular_table_name}_input and #{singular_table_name}.", :green)
        say("* Run 'rails rswag:specs:swaggerize' to update swagger.", :green)
        say("* Make sure any referenced models are updated with eg. has_many :#{plural_table_name}", :green)
        say("* Customize the table and form definition in 'app/admin/#{plural_table_name}_admin.rb'", :green)
        say("* Setup nested route") if is_nested?
        say("* #beAwesome", :green)
      end

    end
  end
end
