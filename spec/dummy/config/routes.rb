Rails.application.routes.draw do

  mount RemoteRailsRakeRunner::Engine => '/rake'
end
