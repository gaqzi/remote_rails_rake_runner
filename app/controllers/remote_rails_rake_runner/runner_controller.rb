require_dependency 'remote_rails_rake_runner/application_controller'

module RemoteRailsRakeRunner
  class RunnerController < ApplicationController
    before_filter :load_rake

    def index
      tasks = Rake.application.tasks.map do |t|
        {
            name: t.to_s,
            args: t.arg_names,
            description: t.comment,
        }
      end

      render json: tasks
    end

    def run
      success = true
      rake_tasks = Rake.application.tasks
      task = rake_tasks.find { |t| t.name == params[:task] }
      return head :not_found unless task

      begin
        output = capture_stdout { task.invoke(*(params[:args] || '').split(',')) }
      rescue => e
        success = false
        output = e.inspect
      ensure
        rake_tasks.each {|task| task.reenable}
      end

      render json: {success: success, output: output}
    end

    private
    def capture_stdout
      previous, $stdout = $stdout, StringIO.new
      yield
      $stdout.string
    ensure
      $stdout = previous
    end

    def load_rake
      return if defined? Rake

      require 'rake'
      load Rails.application.config.try(:remote_rake_runner_rakefile_path) || Rails.root.join('Rakefile').to_s
    end
  end
end
