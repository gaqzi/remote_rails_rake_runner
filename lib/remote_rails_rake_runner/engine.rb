module RemoteRailsRakeRunner
  class Engine < ::Rails::Engine
    isolate_namespace RemoteRailsRakeRunner

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
