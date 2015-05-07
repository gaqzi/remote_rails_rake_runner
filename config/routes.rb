RemoteRailsRakeRunner::Engine.routes.draw do
  root 'runner#index'
  post '/:task', to: 'runner#run', as: :rake
end
