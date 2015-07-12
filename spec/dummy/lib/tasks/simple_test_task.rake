namespace :simple do
  desc 'An output task with no arguments'
  task :hello_world do |t|
    puts 'Hello World!'
  end

  desc 'An output task with arguments'
  task :hello, [:name] do |t, args|
    puts "Hello #{args.name}!"
  end

  desc 'An output task with multiple arguments'
  task :hello_multiple, [:person_a, :person_b] do |t, args|
    puts "Hello #{args.person_a} and #{args.person_b}!"
  end

  desc 'A truly exceptional task'
  task :exceptional do |t, args|
    raise 'Whaaaaaaaa'
  end

  task :hello_default, [:name] do |t, args|
    args.with_defaults(
            name: 'Unknown person'
    )

    puts "Hello #{args.name}!"
  end

  desc 'Output dependent on an environment variable'
  task :hello_environment, [:greeting] do |t, args|
    args.with_defaults(
            greeting: 'Hello'
    )
    puts "#{args.greeting} #{ENV['name']}!"
  end
end
