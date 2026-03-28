# frozen_string_literal: true

module AdminResources
  class Configuration
    attr_reader :models, :custom_pages

    def initialize
      @models = {}
      @custom_pages = []
    end

    # Register a model for admin management
    # Usage: config.register "User", columns: %w[id email created_at]
    # Usage: config.register "User"  (defaults to first 6 columns)
    # Usage: config.register "Product", has_many_through: [{ association: :desk_buddy_versions, join_model: "ProductVersion", foreign_key: :product_id, through_key: :desk_buddy_version_id }]
    # Usage: config.register "Order", custom_actions: [{ name: :ship, label: "Mark Shipped", method: :patch, confirm: "Mark this order as shipped?" }]
    def register(model_name, columns: nil, has_many_through: nil, custom_actions: nil)
      name = model_name.to_s.classify
      @models[name] = {
        columns: columns&.map(&:to_s),
        has_many_through: has_many_through || [],
        custom_actions: custom_actions || []
      }
    end

    def model_names
      @models.keys
    end

    # Register a custom sidebar page that routes to the host app
    # Usage: config.add_page "STL Models", path: "/admin/stl_models", icon: "📦"
    def add_page(label, path:, icon: nil)
      @custom_pages << { label: label, path: path, icon: icon }
    end
  end
end
