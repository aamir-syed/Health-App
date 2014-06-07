default_run_options[:pty] = true

require 'bundler/capistrano'
set :application, "healthapp"
set :repository,  "/Users/aamirsyed/myapp"
set :deploy_to, "/var/www/#{application}" #path to your app on the production server 


# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :scm, :git
set :branch, "master"
set :deploy_via, :copy
set :shallow_clone, 1


set :domain, '54.187.126.141'


role :web, domain
role :app, domain
role :db,  domain, :primary => true

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"
after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

#Passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end


set :user, "deploy" #this is the ubuntu user we created
set :password, "deploy" #deploy's password
set :use_sudo, false

set :mysql_user, "deploy" #this is the mysql user we created
set :mysql_password, "secret"

after "deploy:setup", "db_yml:create"
after "deploy:update_code", "db_yml:symlink"

namespace :db_yml do
  desc "Create database.yml in shared path" 
  task :create do
    config = {
              "production" => 
              {
                "adapter" => "mysql2",
                "socket" => "/var/run/mysqld/mysqld.sock",
                "username" => mysql_user,
                "password" => mysql_password,
                "database" => "#{application}_production"
              }
            }
    put config.to_yaml, "#{shared_path}/database.yml"
  end

  desc "Make symlink for database.yml" 
  task :symlink do
    run "ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml" 
  end
end