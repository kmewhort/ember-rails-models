module EmberRailsModels
  mattr_accessor :app_root
  mattr_accessor :app_name

  module Rails
    class Engine < ::Rails::Engine
      initializer "EmberRailsModels.store_app_root" do |app|
        EmberRailsModels.app_root = app.root
        EmberRailsModels.app_name = app.class.parent_name
      end
    end
  end
end