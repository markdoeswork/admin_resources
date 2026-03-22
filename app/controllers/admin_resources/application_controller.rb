module AdminResources
  class ApplicationController < ActionController::Base
    before_action :authenticate_admin_user!
    layout "admin_resources/admin"

    def after_sign_in_path_for(resource)
      admin_resources.root_path
    end

    def after_sign_out_path_for(resource_or_scope)
      admin_resources.new_admin_user_session_path
    end

    helper_method :admin_models, :admin_path_for

    def admin_models
      AdminResources.model_names
    end

    def admin_path_for(model_name, action = :index, resource = nil)
      route_name = model_name.underscore.pluralize
      case action
      when :index
        admin_resources.send("#{route_name}_path")
      when :new
        admin_resources.send("new_#{route_name.singularize}_path")
      when :show
        admin_resources.send("#{route_name.singularize}_path", resource)
      when :edit
        admin_resources.send("edit_#{route_name.singularize}_path", resource)
      end
    end
  end
end
