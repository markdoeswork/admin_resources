module AdminResources
  class DashboardController < ApplicationController
    def index
      puts "[AdminResources::DashboardController] index - showing dashboard"
      @model_counts = AdminResources.model_names.each_with_object({}) do |model_name, hash|
        hash[model_name] = model_name.constantize.count
      end
    end
  end
end
