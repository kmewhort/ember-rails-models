module EmberRailsModels::DbAdapters
  class ActiveRecordAttributeAdapter < BaseAttributeAdapter
    def attribute_name_to_ember_type(attribute_name)
      column = model_class.columns.find {|col| col.name == attribute_name.to_s}

      attribute_type_to_ember_type(column.type)
    end

    def attribute_type_to_ember_type(active_record_type)
      # TODO: need some special case handling for some type mappings
      case active_record_type.to_s
      when "jsonb"
        "object"
      when "float"
        "number"
      else
        active_record_type.to_s.downcase
      end
    end
  end
end
