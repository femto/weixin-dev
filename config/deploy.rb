require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require "mina_sidekiq/tasks"
require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
#require 'mina/rvm'    # for rvm support. (http://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, 'weixin-dev.com'

set :deploy_to, '/home/deploy/www/weixin-dev.com'
set :repository, 'https://github.com/femto/weixin-dev.git'
set :branch, 'master'

set :keep_releases, 3

set :rails_env, 'production'

# For system-wide RVM install.
#   set :rvm_path, '/usr/local/rvm/bin/rvm'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.

set :shared_paths, ['config/database.yml', 'log', 'public/uploads', "config/config.yml", "config/secrets.yml"]

# Optional settings:
  set :user, 'deploy'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  ## Be sure to commit your .rbenv-version to your repository.
  invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  #invoke :'rvm:use[ruby-2.2.1]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do

  # base_names = ["yml"]
  # shared_paths.each do |path|
  #   is_file = base_names.include?(File.basename(path).split(".")[-1])
  #   setup_command = is_file ? "touch" : "mkdir -p"
  #   base_path = "#{deploy_to}/#{shared_path}/#{path}"
  #   queue! %[#{setup_command} #{base_path}]
  #   if !is_file
  #     queue! %[chmod g+rx,u+rwx #{base_path}]
  #   else
  #     queue  %[echo "-----> Be sure to edit '#{base_path}'"]
  #   end
  # end

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml'."]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/config.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/config.yml'."]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/secrets.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/secrets.yml'."]

  queue! %[mkdir -p "#{deploy_to}/shared/public/uploads"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/uploads"]

  # sidekiq needs a place to store its pid file and log file
  queue! %[mkdir -p "#{deploy_to}/shared/pids/"]
  queue! %[mkdir -p "#{deploy_to}/shared/log/"]

end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.

    # stop accepting new workers
    invoke :'sidekiq:quiet'
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_create'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    to :launch do
      queue "mkdir -p #{deploy_to}/#{current_path}/tmp/"
      queue "touch #{deploy_to}/#{current_path}/tmp/restart.txt"
      invoke :'sidekiq:restart'
    end
  end
end

desc "Shows logs."
task :logs do
  queue %[cd #{deploy_to!} && tail -f #{shared_path}/log/#{rails_env}.log]
end

namespace :rails do

  desc "create db"
  task :db_create => :environment do
      queue %{
        echo "-----> Creating database"
        #{echo_cmd %[#{rake} db:create]}
      }
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers

