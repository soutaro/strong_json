require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => [:spec, :typecheck, :"example:typecheck"]

task :typecheck do
  sh "bundle exec steep check"
end

namespace :example do
  task :typecheck do
    sh "bundle exec steep check --steepfile=example/Steepfile"
  end
end
