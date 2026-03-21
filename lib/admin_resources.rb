# frozen_string_literal: true

require_relative "admin_resources/version"
require_relative "admin_resources/configuration"
require_relative "admin_resources/engine"

module AdminResources
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    # Shorthand accessors used throughout the engine
    def models
      configuration.models
    end

    def model_names
      configuration.model_names
    end
  end
end
