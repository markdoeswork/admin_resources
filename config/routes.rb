AdminResources::Engine.routes.draw do
  devise_for :admin_users,
             class_name: "AdminResources::AdminUser",
             controllers: { sessions: "admin_resources/sessions" },
             module: :devise,
             path: "",
             path_names: { sign_in: "login", sign_out: "logout" }

  # Dynamically generate routes for every registered model
  AdminResources.model_names.each do |model_name|
    resources model_name.underscore.pluralize.to_sym,
              controller: "resources",
              defaults: { model: model_name }
  end

  resources :admin_users, only: [:index, :new, :create, :edit, :update, :destroy]

  root to: "dashboard#index"
end
