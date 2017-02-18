module EmberRailsModels::DbAdapters
  class ActiveRecordAttributeAdapter < BaseAttributeAdapter
    def attribute_name_to_ember_type(attribute_name)
      column = model_class.columns.find {|col| col.name == attribute_name.to_s}
      raise "Unable to find column named '#{attribute_name}' for '#{model_class.to_s}'" if column.nil?

      attribute_type_to_ember_type(column.type)
    end

    def attribute_type_to_ember_type(active_record_type)
      # TODO: need some special case handling for some type mappings
      case active_record_type.to_s.downcase
      when "hash", "jsonb"
        "object"
      when "float", "integer"
        "number"
      when "datetime"
        "date"
      else
        active_record_type.to_s.downcase
      end
    end
  end
end
