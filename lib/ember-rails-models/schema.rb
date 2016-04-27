module EmberRailsModels
  class Schema
    def self.all
      # load the application's serializers
      Dir.glob("#{EmberRailsModels.app_root}/app/serializers/**/*.rb") do |rb_file|
        require rb_file
      end

      # gather and construct the schemas from the ActiveModelSerializer schemas
      serializer_classes.map do |serializer_class|
        schema = self.new serializer_class

        # only create a model for serializers with an underlying model
        begin
          schema.model_class
        rescue NameError => e
          schema = nil
        end

        schema
      end.compact
    end

    def initialize(serializer_class)
      @serializer_class = serializer_class
    end

    def attributes
      attrs = []
      unless serializer_attributes.blank?
        attrs += serializer_attributes.reject{|attr| attr == :id}.map do |attr_name|
          {
              name: attr_name.to_s.camelize(:lower),
              type: db_adapter.attribute_name_to_ember_type(attr_name)
          }.compact
        end
      end

      unless serializer_attribute_methods.blank?
        attrs += serializer_attribute_methods.map do |method_name, type|
          {
              name: method_name.to_s.camelize(:lower),
              type: db_adapter.attribute_type_to_ember_type(type)
          }
        end
      end
      attrs
    end

    def associations
      serializer_associations.map do |name, assoc|
        {
            name: name.to_s.camelize(:lower),
            references: name.to_s.singularize.camelize(:lower),
            type: serializer_to_ember_relation_type(assoc),
        }.tap do |hash|
          if assoc.polymorphic?
            hash[:properties] = {
                polymorphic: true
            }
          end
        end
      end
    end

   def model_name
     model_class.to_s
   end

    def model_class
      @serializer_class.to_s.gsub(/Serializer/, '').constantize
    end

    private
    def self.serializer_classes
      ActiveModel::Serializer.descendants.select{|c| self.includes_ember_rails_model_serializer?(c)}.sort_by(&:name)
    end

    def self.includes_ember_rails_model_serializer?(klass)
      klass.ancestors.any?{|a| a.instance_variable_get(:@ember_rails_models)}
    end

    def serializer_attributes
      @serializer_class.instance_variable_get(:@_attributes).reject{|attr| attr.in? serializer_attribute_methods.keys }
    end

    def serializer_associations
      @serializer_class.instance_variable_get :@_associations
    end

    def serializer_attribute_methods
      @serializer_class.get_attribute_methods
    end

    def serializer_to_ember_relation_type(association)
      association_class = association.class.to_s.gsub(/.*\:\:/, '').camelize(:lower)
      case association_class
      when "hasOne"
        # ember data only supports hasOne through belongsTo
        "belongsTo"
      else
        association_class
      end
    end

    def db_adapter
      @adapter ||= begin
        if model_class.ancestors.map(&:to_s).include? 'ActiveRecord::Base'
          DbAdapters::ActiveRecordAttributeAdapter.new model_class
        elsif model_class.included_modules.map(&:to_s).include? 'Mongoid::Document'
          DbAdapters::MongoidAttributeAdapter.new model_class
        else
          raise "Unnown model type (neither ActiveRecord nor Mongoid::Document)"
        end
      end
    end
  end
end

