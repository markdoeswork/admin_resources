module AdminResources
  class DeviseFailureApp < Devise::FailureApp
    def redirect_url
      if scope == :admin_user
        "/admin/login"
      else
        super
      end
    end

    def respond
      if http_auth?
        http_auth
      else
        redirect
      end
    end
  end
end
