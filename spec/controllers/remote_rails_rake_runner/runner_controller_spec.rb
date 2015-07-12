require_relative '../../spec_helper'
require_relative '../../rails_helper'

module RemoteRailsRakeRunner
  RSpec.describe RunnerController, type: :controller do
    routes { Engine.routes }

    context '#index' do
      it 'returns a list of rake tasks with descriptions' do
        get :index, format: :json

        json = JSON.parse(response.body)
        expect(json).to include({'name' => 'simple:hello_world', 'args' => [], 'description' => nil})
        expect(json).to include({'name' => 'simple:hello', 'args' => ['name'], 'description' => nil})
      end
    end

    context '#run' do
      context "task doesn't exist" do
        it 'returns 404' do
          post :run, task: 'simply:missing'

          expect(response).to have_http_status(:missing)
        end
      end

      context 're-enabling tasks' do
        it 're-enables all tasks' do
          post :run, format: :json, task: 'simple:hello_world'
          json = JSON.parse(response.body)
          expect(json['output']).to eq("Hello World!\n")

          post :run, format: :json, task: 'simple:hello_world'
          json = JSON.parse(response.body)
          expect(json['output']).to eq("Hello World!\n")
        end
      end

      context 'task without arguments' do
        it 'runs successfully' do
          post :run, format: :json, task: 'simple:hello_world'

          json = JSON.parse(response.body)
          expect(json['output']).to eq("Hello World!\n")
        end

        it 'handles exceptions thrown by task' do
          post :run, format: :json, task: 'simple:exceptional'

          json = JSON.parse(response.body)
          expect(json['success']).to_not be
          expect(json['output']).to eq '#<RuntimeError: Whaaaaaaaa>'
        end
      end

      context 'task with arguments' do
        it 'runs successfully with a single argument' do
          post :run, format: :json, task: 'simple:hello', args: 'Björn'

          json = JSON.parse(response.body)
          expect(json['output']).to eq("Hello Björn!\n")
        end

        it 'runs successfully with multiple arguments' do
          post :run, format: :json, task: 'simple:hello_multiple', args: 'Andersson,Björn'

          json = JSON.parse(response.body)
          expect(json['output']).to eq("Hello Andersson and Björn!\n")
        end

        it 'runs successfully with default argument when args is empty' do
          post :run, format: :json, task: 'simple:hello_default', args: ''

          json = JSON.parse(response.body)
          expect(json['output']).to eq("Hello Unknown person!\n")
        end
      end

      context 'setting a one-off environment variable' do
        it 'task without arguments runs successfully' do
          post :run, format: :json, task: 'simple:hello_environment', environment: {name: 'World'}

          json = JSON.parse(response.body)
          expect(json['output']).to eq("Hello World!\n")
        end

        it 'task with arguments' do
          post :run, format: :json, task: 'simple:hello_environment', environment: {name: 'World'}, args: 'Ehlo'

          json = JSON.parse(response.body)
          expect(json['output']).to eq("Ehlo World!\n")
        end

        it 'resets the env to the old state' do
          old_env = ENV.to_h
          post :run, format: :json, task: 'simple:hello_environment', environment: {name: 'World'}

          expect(ENV.to_h).to eq(old_env)
        end

        it 'works when overridden environment variable is empty' do
          post :run, format: :json, task: 'simple:hello_environment', environment: ''

          json = JSON.parse(response.body)
          expect(json['output']).to eq("Hello !\n")
        end
      end
    end
  end
end
