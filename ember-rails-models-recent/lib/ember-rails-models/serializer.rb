module EmberRailsModels
  module Serializer
    extend ActiveSupport::Concern

    included do
      @ember_rails_models = true
    end

    module ClassMethods
      def attribute_methods(attribute_methods)
        @attribute_methods = attribute_methods

        # ActiveModelSerializer just recognizes attribute methods as normal attributes
        attribute_methods.keys.each do |attr|
          self.attributes attr
        end
      end

      def get_attribute_methods
        @attribute_methods.nil? ? {} : @attribute_methods
      end
    end
  end
end
