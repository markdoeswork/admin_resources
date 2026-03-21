module AdminResources
  class AdminUser < ApplicationRecord
    self.table_name = "admin_resources_admin_users"

    devise :database_authenticatable, :recoverable, :rememberable, :validatable
  end
end
