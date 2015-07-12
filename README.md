# Remote Rails Rake Runner

The goal to deal with one problem: The startup time of a big Rails
project when running a functional suite across multiple servers.

## Background
The project this lil' app was started on is running a Cucumber suite
that spans a total of 10 concurrent runners, all of whom need data at
different times. It was originally developed with rake tasks that was
reused from local development and run on the servers remotely through SSH.

But ~30s startup time per task was starting to have too big of an effect,
so this gem was born with the hope of removing all the starting cost while
keeping it really simple to reuse the already existing rake tasks.

## Installation

Add to your Gemfile and ensure you mount the app in your routes.

To your Gemfile:

```ruby
gem 'remote_rails_rake_runner'
```

To your `routes.rb`:

```ruby
Rails.application.routes.draw do

  mount RemoteRailsRakeRunner::Engine => '/rake'
end
```

## Configuration

You can specify the path to your `Rakefile` by setting the option
`Rails.application.config.remote_rake_runner_rakefile_path` which defaults to
`Rails.root.join('Rakefile').to_s`.

## Usage

The app exposes two endpoints, a listing of all the rake tasks and the actual
runner. To run a task with arguments just put the arguments in into the argument
`args` separated by commas. The task will not be considered successful if it
raises an exception, otherwise it's assumed to have been successful.

To override an environment variable for one task run set the variable in the
`environment` variable which acts like a hash.

If you mount the app under `/rake` as suggested above:

```shell
$ curl http://localhost:3000/rake
[{"name":"about","args":[],"description":null}, …] # a listing of all tasks (like rake -T)

$ curl http://localhost:3000/rake/simple:hello -d args=Björn
{"success":true,"output":"Hello Björn!\n"}

$ curl http://localhost:3000/rake/simple:hello_environment -d 'environment[name]=Björn&args=Ahlo'
{"success":true,"output":"Ahlo Björn!\n"}
```

## Arguments

* `args`: A comma separated list string of arguments passed to the rake task,
  like on the command line
* `environment`: A hash of overridden values.  
  Example in Ruby: `{environment: {name: 'Björn'}}` or in curl
  `environment[name]=Björn`.

## Acknowledgements

The running and capturing of output that was taken from
[this blog post](http://andowebsit.es/blog/noteslog.com/post/how-to-run-rake-tasks-programmatically/)
by [Andrea Ercolino].

[Andrea Ercolino]: https://github.com/aercolino/

## License

This project rocks and uses MIT-LICENSE.
