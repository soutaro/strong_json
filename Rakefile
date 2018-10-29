require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => [:spec, :typecheck, :"example:typecheck"]

task :typecheck do
  sh "bundle exec steep check --strict lib"
end

namespace :example do
  task :typecheck do
    sh "bundle exec steep check --strict -I sig -I example example"
  end
end
