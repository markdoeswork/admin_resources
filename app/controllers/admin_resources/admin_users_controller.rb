module AdminResources
  class AdminUsersController < ApplicationController
    def index
      @admin_users = AdminUser.order(:email)
    end

    def new
      @admin_user = AdminUser.new
    end

    def create
      @admin_user = AdminUser.new(admin_user_params)
      if @admin_user.save
        redirect_to admin_resources.admin_users_path, notice: "Admin user created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @admin_user = AdminUser.find(params[:id])
    end

    def update
      @admin_user = AdminUser.find(params[:id])
      params_to_update = admin_user_params
      params_to_update.delete(:password) if params_to_update[:password].blank?
      params_to_update.delete(:password_confirmation) if params_to_update[:password].blank?

      if @admin_user.update(params_to_update)
        redirect_to admin_resources.admin_users_path, notice: "Admin user updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @admin_user = AdminUser.find(params[:id])
      if @admin_user == current_admin_user
        redirect_to admin_resources.admin_users_path, alert: "You cannot delete your own account."
      else
        @admin_user.destroy
        redirect_to admin_resources.admin_users_path, notice: "Admin user deleted."
      end
    end

    private

    def admin_user_params
      params.require(:admin_user).permit(:email, :password, :password_confirmation)
    end
  end
end
