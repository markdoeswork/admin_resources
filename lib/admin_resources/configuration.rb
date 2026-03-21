# frozen_string_literal: true

module AdminResources
  class Configuration
    attr_reader :models

    def initialize
      @models = {}
    end

    # Register a model for admin management
    # Usage: config.register "User", columns: %w[id email created_at]
    # Usage: config.register "User"  (defaults to first 6 columns)
    def register(model_name, columns: nil)
      name = model_name.to_s.classify
      @models[name] = { columns: columns&.map(&:to_s) }
    end

    def model_names
      @models.keys
    end
  end
end
