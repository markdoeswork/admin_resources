module AdminResources
  class SessionsController < Devise::SessionsController
    layout "admin_resources/admin_login"
  end
end
