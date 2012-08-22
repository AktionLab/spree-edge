require 'bundler/capistrano'
require 'rvm/capistrano'

ssh_options[:username] = 'deployer'
ssh_options[:forward_agent] = true

set :application, "spree-edge"
set :repository,  "git@github.com:AktionLab/spree-edge.git"
set :scm, :git
set :deploy_to, "/home/daniel/#{application}"
set :rvm_ruby_string, '1.9.3-p0@spree'
set :rvm_type, :user
set :rails_env, 'production'
set :use_sudo, false
set :keep_releases, 3
set :ec2_server, 'bzlabs.org'
set :port, 2222
set :configs, %w(config/database.yml config/unicorn.rb)

role :web, "#{ec2_server}"                   # Your HTTP server, Apache/etc
role :app, "#{ec2_server}"                   # This may be the same as your `Web` server
role :db,  "#{ec2_server}", :primary => true # This is where Rails migrations will run

# if you want to clean up old releases on each deploy uncomment this:
#before 'deploy:assets:precompile', 'deploy:symlink_shared'
after 'deploy:config_files', 'deploy:rake_tasks'
after 'deploy:rake_tasks', 'nginx:config'
after 'nginx:config', 'nginx:reload'
after 'deploy', 'deploy:config_files'
#after 'deploy', 'deploy:cleanup'

namespace :deploy do
  %w(start stop restart).each do |action|
    #task(action) { run "cd #{current_path} && script/unicorn #{action}" }
  end

  task :config_files, :except => { :no_release => true } do
    run(configs.map {|file| "cp #{shared_path}/#{file} #{release_path}/#{file}"}.join(' && '))
  end

  task :rake_tasks do
    run "cd #{release_path} && RAILS_ENV=production bundle exec rake db:migrate"
  end
end

namespace :nginx do
  task :config do
    run "sudo rm -f /etc/nginx/sites-enabled/#{application} && sudo ln -nfs #{release_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
  end

  task :reload do
    run "sudo /etc/init.d/nginx reload"
  end
end
