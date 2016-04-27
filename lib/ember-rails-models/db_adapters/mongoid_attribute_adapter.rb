module EmberRailsModels::DbAdapters
  class MongoidAttributeAdapter < BaseAttributeAdapter
    def attribute_name_to_ember_type(attribute_name)
      field = mongo_field_by_name(attribute_name.to_s)
      attribute_type_to_ember_type(field.type)
    end

    def attribute_type_to_ember_type(mongo_type)
      # TODO: need some special case handling for some type mappings
      case mongo_type.to_s
      when "BSON::ObjectId"
        "string"
      when "Hash"
        "object"
      when "Float"
        "number"
      else
        mongo_type.to_s.downcase.gsub(/^mongoid\:\:/, '')
      end
    end

    private
    def mongoid_field_by_name(name)
      db_attr = case name
      when "id"
        "_id"
      else
        name
      end
      model_class.fields[db_attr]
    end
  end
end
