module EmberRailsModels::DbAdapters
  class BaseAttributeAdapter
    attr_accessor :model_class

    def initialize(model_class)
      @model_class = model_class
    end

    def attribute_name_to_ember_type(attribute_name)
      raise "Pure virtual"
    end

    def attribute_type_to_ember_type
      raise "Pure virtual"
    end
  end
end
