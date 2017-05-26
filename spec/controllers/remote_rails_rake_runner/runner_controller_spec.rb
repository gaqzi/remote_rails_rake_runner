require_relative '../../spec_helper'
require_relative '../../rails_helper'

module RemoteRailsRakeRunner
  RSpec.describe RunnerController, type: :request do
    include Engine.routes.url_helpers

    context '#index' do
      it 'returns a list of rake tasks with descriptions' do
        get remote_rails_rake_runner_path(format: :json)

        json = JSON.parse(response.body)
        expect(json).to include({'name' => 'simple:hello_world', 'args' => [], 'description' => nil})
        expect(json).to include({'name' => 'simple:hello', 'args' => ['name'], 'description' => nil})
      end
    end

    context '#run' do
      context "task doesn't exist" do
        it 'returns 404' do
          post rake_path('simply:missing')

          expect(response).to have_http_status(:missing)
        end
      end

      context 're-enabling tasks' do
        it 're-enables all tasks' do
          post rake_path('simple:hello_world', format: :json)
          json = JSON.parse(response.body)
          expect(json['output']).to eq("Hello World!\n")

          post rake_path('simple:hello_world', format: :json)
          json = JSON.parse(response.body)
          expect(json['output']).to eq("Hello World!\n")
        end
      end

      context 'task without arguments' do
        it 'runs successfully' do
          post rake_path('simple:hello_world', format: :json)

          json = JSON.parse(response.body)
          expect(json['output']).to eq("Hello World!\n")
        end

        it 'handles exceptions thrown by task' do
          post rake_path('simple:exceptional', format: :json)

          json = JSON.parse(response.body)
          expect(json['success']).to_not be
          expect(json['output']).to eq '#<RuntimeError: Whaaaaaaaa>'
        end
      end

      context 'task with arguments' do
        it 'runs successfully with a single argument' do
          post rake_path('simple:hello', format: :json, args: 'Björn')

          json = JSON.parse(response.body)
          expect(json['output']).to eq("Hello Björn!\n")
        end

        it 'runs successfully with multiple arguments' do
          post rake_path('simple:hello_multiple', format: :json, args: 'Andersson,Björn')

          json = JSON.parse(response.body)
          expect(json['output']).to eq("Hello Andersson and Björn!\n")
        end

        it 'runs successfully with default argument when args is empty' do
          post rake_path('simple:hello_default', format: :json, args: '')

          json = JSON.parse(response.body)
          expect(json['output']).to eq("Hello Unknown person!\n")
        end
      end

      context 'setting a one-off environment variable' do
        it 'task without arguments runs successfully' do
          post rake_path('simple:hello_environment', format: :json, environment: {name: 'World'})

          json = JSON.parse(response.body)
          expect(json['output']).to eq("Hello World!\n")
        end

        it 'task with arguments' do
          post rake_path('simple:hello_environment', format: :json, environment: {name: 'World'}, args: 'Ehlo')

          json = JSON.parse(response.body)
          expect(json['output']).to eq("Ehlo World!\n")
        end

        it 'resets the env to the old state' do
          old_env = ENV.to_h
          post rake_path('simple:hello_environment', format: :json, environment: {name: 'World'})

          expect(ENV.to_h).to eq(old_env)
        end

        it 'works when overridden environment variable is empty' do
          post rake_path('simple:hello_environment', format: :json, environment: '')

          json = JSON.parse(response.body)
          expect(json['output']).to eq("Hello !\n")
        end
      end
    end
  end
end
