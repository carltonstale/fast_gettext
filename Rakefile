require 'bundler/setup'
require 'bundler/gem_tasks'
require 'bump/tasks'
require 'wwtd/tasks'

task :default => "wwtd:local"

task :spec do
  sh "rspec spec"
end

task :benchmark do
  puts "Running on #{RUBY_DESCRIPTION}"
  %w[baseline ideal fast_gettext original i18n_simple].each do |bench|
    puts `ruby -I. benchmark/#{bench}.rb`
    puts ""
  end
end

task :namespaces do
  puts `ruby benchmark/namespace/original.rb`
  puts `ruby benchmark/namespace/fast_gettext.rb`
end
