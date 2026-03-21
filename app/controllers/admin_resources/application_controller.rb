module AdminResources
  class ApplicationController < ActionController::Base
    before_action :authenticate_admin_resources_admin_user!
    layout "admin_resources/admin"

    helper_method :admin_models, :admin_path_for

    def admin_models
      AdminResources.model_names
    end

    def admin_path_for(model_name, action = :index, resource = nil)
      route_name = model_name.underscore.pluralize
      case action
      when :index
        send("admin_resources_#{route_name}_path")
      when :new
        send("new_admin_resources_#{route_name.singularize}_path")
      when :show
        send("admin_resources_#{route_name.singularize}_path", resource)
      when :edit
        send("edit_admin_resources_#{route_name.singularize}_path", resource)
      end
    end
  end
end
