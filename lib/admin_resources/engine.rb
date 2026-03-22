# frozen_string_literal: true

require "rails/engine"
require "devise"

module AdminResources
  class Engine < ::Rails::Engine
    isolate_namespace AdminResources

    initializer "admin_resources.warden_failure_app" do
      Devise.setup do |config|
        config.warden do |manager|
          manager.failure_app = AdminResources::DeviseFailureApp
        end
      end
    end

    initializer "admin_resources.load_admin_user_migration" do |app|
      # Add our migrations to the host app's migration path
      config.paths["db/migrate"].expanded.each do |expanded_path|
        app.config.paths["db/migrate"] << expanded_path
      end
    end

    config.generators do |g|
      g.test_framework nil
    end
  end
end
