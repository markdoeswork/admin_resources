module AdminResources
  class ResourcesController < ApplicationController
    before_action :set_model_class
    before_action :set_resource, only: %i[show edit update destroy custom_action]

    helper_method :model_class, :model_name, :index_columns, :form_columns, :admin_value_display, :join_associations, :custom_actions

    def index
      puts "[AdminResources::ResourcesController] index for #{model_name}"
      @resources = model_class.all.order(id: :desc)
    end

    def show
      puts "[AdminResources::ResourcesController] show #{model_name}##{@resource.id}"
    end

    def new
      puts "[AdminResources::ResourcesController] new #{model_name}"
      @resource = model_class.new
    end

    def create
      puts "[AdminResources::ResourcesController] create #{model_name}"
      @resource = model_class.new(resource_params)
      if @resource.save
        sync_join_associations
        redirect_to admin_path_for(model_name, :show, @resource), notice: "#{model_name} was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      puts "[AdminResources::ResourcesController] edit #{model_name}##{@resource.id}"
    end

    def update
      puts "[AdminResources::ResourcesController] update #{model_name}##{@resource.id}"
      if @resource.update(resource_params)
        sync_join_associations
        redirect_to admin_path_for(model_name, :show, @resource), notice: "#{model_name} was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      puts "[AdminResources::ResourcesController] destroy #{model_name}##{@resource.id}"
      @resource.destroy
      redirect_to admin_path_for(model_name, :index), notice: "#{model_name} was successfully deleted."
    end

    # Dispatches to a host-app controller action via a configured custom action.
    # The host app must define a route that this proxies to, specified as `handler`.
    # If no handler is configured, falls back to calling a same-named method on the resource.
    def custom_action
      action_name_param = params[:custom_action]
      action_config = custom_actions.find { |a| a[:name].to_s == action_name_param }
      unless action_config
        redirect_to admin_path_for(model_name, :show, @resource), alert: "Unknown action."
        return
      end

      handler = action_config[:handler]
      if handler
        # handler is a callable (proc/lambda) that receives (resource, controller)
        handler.call(@resource, self)
      else
        # Default: call a method by the action name on the resource
        if @resource.respond_to?(action_name_param)
          @resource.public_send(action_name_param)
          redirect_to admin_path_for(model_name, :show, @resource),
                      notice: "#{action_config[:label] || action_name_param} completed."
        else
          redirect_to admin_path_for(model_name, :show, @resource), alert: "Action not implemented."
        end
      end
    end

    private

    def set_model_class
      model_param = params[:model]
      unless AdminResources.model_names.include?(model_param)
        raise ActiveRecord::RecordNotFound, "Model '#{model_param}' not registered in AdminResources"
      end
      @model_class = model_param.constantize
    end

    def set_resource
      @resource = model_class.find(params[:id])
    end

    def model_class
      @model_class
    end

    def model_name
      model_class.name
    end

    def index_columns
      config = AdminResources.models[model_name]
      config&.dig(:columns) || model_class.column_names.first(6)
    end

    def form_columns
      model_class.column_names - %w[id created_at updated_at]
    end

    # Returns [display_text, link_path_or_nil]
    def admin_value_display(resource, column)
      unless resource.respond_to?(column)
        return ["[invalid column: #{column}]", nil]
      end

      value = resource.send(column)
      return [nil, nil] if value.nil?

      if column.end_with?("_id") && value.present?
        assoc_name = column.sub(/_id$/, "")
        association = resource.class.reflect_on_association(assoc_name.to_sym)

        if association && association.macro == :belongs_to
          assoc_class = association.klass
          assoc_model = assoc_class.name

          if AdminResources.model_names.include?(assoc_model)
            associated_record = assoc_class.find_by(id: value)
            if associated_record
              display = "#{assoc_model} ##{value}"
              display = associated_record.name    if associated_record.respond_to?(:name) && associated_record.name.present?
              display = associated_record.version if associated_record.respond_to?(:version) && associated_record.version.present?
              display = associated_record.email   if associated_record.respond_to?(:email) && associated_record.email.present?
              return [display, admin_path_for(assoc_model, :show, associated_record)]
            end
          end
        end
      end

      [value, nil]
    end

    def resource_params
      permitted = form_columns.map do |col|
        column = model_class.columns_hash[col]
        if column&.array?
          { col.to_sym => [] }
        else
          col.to_sym
        end
      end
      params.require(model_class.model_name.param_key).permit(*permitted)
    end

    def join_associations
      AdminResources.models[model_name]&.dig(:has_many_through) || []
    end

    def custom_actions
      AdminResources.models[model_name]&.dig(:custom_actions) || []
    end

    def sync_join_associations
      join_associations.each do |jdef|
        join_model_class = jdef[:join_model].safe_constantize
        next unless join_model_class

        foreign_key   = jdef[:foreign_key]
        through_key   = jdef[:through_key]
        param_key     = "#{jdef[:association]}_ids"
        submitted_ids = (params[model_class.model_name.param_key] || {})[param_key]

        next if submitted_ids.nil?

        new_ids = Array(submitted_ids).map(&:to_i).reject(&:zero?)

        existing = join_model_class.where(foreign_key => @resource.id)
        existing_ids = existing.pluck(through_key)

        to_add    = new_ids - existing_ids
        to_remove = existing_ids - new_ids

        join_model_class.where(foreign_key => @resource.id, through_key => to_remove).destroy_all if to_remove.any?
        to_add.each { |tid| join_model_class.create!(foreign_key => @resource.id, through_key => tid) }
      end
    end
  end
end
