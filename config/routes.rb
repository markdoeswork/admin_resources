AdminResources::Engine.routes.draw do
  devise_for :admin_users,
             class_name: "AdminResources::AdminUser",
             module: :devise,
             path: "",
             path_names: { sign_in: "login", sign_out: "logout" }

  # Dynamically generate routes for every registered model
  AdminResources.model_names.each do |model_name|
    resources model_name.underscore.pluralize.to_sym,
              controller: "resources",
              defaults: { model: model_name }
  end

  root to: "dashboard#index"
end
