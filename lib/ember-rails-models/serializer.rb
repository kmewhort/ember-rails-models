module EmberRailsModels
  module Serializer
    extend ActiveSupport::Concern

    included do
      @ember_rails_models = true
    end

    module ClassMethods
      def attribute_methods(attribute_methods)
        @attribute_methods = {} if @attribute_methods.nil?
        @attribute_methods.merge! attribute_methods

        # ActiveModelSerializer just recognizes attribute methods as normal attributes
        attribute_methods.keys.each do |attr|
          self.attributes attr
        end
      end

      def get_attribute_methods
        @attribute_methods.nil? ? {} : @attribute_methods
      end

      def has_one(*args)
        if args.last.is_a?(Hash) && args.last[:async]
          # wo don't want the standard serialization when async, so just add methods to return the
          # foreign id, and skip the has_one call altogether (stubbing out won't work as it does for has_many,
          # as this is actually a BelongsTo in ember and so we still need this foreign id)
          attrs = args[0..-2]

          attrs.each do |attr|
            id_accessor_name = "#{attr}_id"
            attribute_methods id_accessor_name => :integer
            self.send :define_method, id_accessor_name do
              object.send(attr).try(:id)
            end

            @async_has_ones = [] if @async_has_ones.nil?
            @async_has_ones << attr
          end
        else
          super *args
        end
      end

      def has_many(*args)
        if args.last.is_a?(Hash) && args.last[:async]
          attrs = args[0..-2]
          stub_async *attrs
          super *attrs
        else
          super *args
        end
      end

      def stub_async(*async_attrs)
        async_attrs.each do |attr|
          # add a dummy method that returns an empty array that ActiveModelSerializer will delegate to
          self.send :define_method, attr do
            []
          end
        end
      end
    end
  end
end
