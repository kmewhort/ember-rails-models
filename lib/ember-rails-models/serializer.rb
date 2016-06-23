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

      def asynchronous(*async_attrs)
        async_attrs.each do |attr|
          # add a dummy method that returns an empty array that ActiveModelSerializer will delegate to
          # TODO: need to return nil for a has_one relationship?
          self.send :define_method, attr do
            []
          end
        end
      end
    end
  end
end
