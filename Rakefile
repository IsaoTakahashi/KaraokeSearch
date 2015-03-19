require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require './app.rb'

require 'rspec/core/rake_task'
desc "run spec"
task :default => [:spec]

RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = 'spec/*_spec.rb'
    spec.rspec_opts = %w(--color --format progress)
end

namespace :unicorn do

  ##
  # Tasks
  ## 
  desc "Start unicorn"
  task(:start) {
    config = "/usr/local/service/KaraokeSearch/config/unicorn.rb"
    sh "bundle exec unicorn -c #{config} -E production -D"
  }

  desc "Stop unicorn"
  task(:stop) { unicorn_signal :QUIT }

  desc "Restart unicorn with USR2"
  task(:restart) { unicorn_signal :USR2 }

  desc "Increment number of worker processes"
  task(:increment) { unicorn_signal :TTIN }

  desc "Decrement number of worker processes"
  task(:decrement) { unicorn_signal :TTOU }

  desc "Unicorn pstree (depends on pstree command)"
  task(:pstree) do
    sh "pstree '#{unicorn_pid}'"
  end

  ##
  # Helpers
  ##
  def unicorn_signal signal
    Process.kill signal, unicorn_pid
  end

  def unicorn_pid
    begin
      File.read("/tmp/pids/unicorn.pid").to_i
    rescue Errno::ENOENT
      raise "Unicorn doesn't seem to be running"
    end
  end

  def rails_root
    require "pathname"
    Pathname.new(__FILE__) + "../"
  end 
end
