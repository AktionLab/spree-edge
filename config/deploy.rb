ssh_options[:username] = 'deployer'
ssh_options[:forward_agent] = true

set :application, "spree-edge"
set :repository,  "git@github.com:AktionLab/spree-edge.git"
set :scm, :git
set :deploy_to, "/var/www/#{application}"
set :rvm_ruby_string, '1.9.3-p0@spree'
set :rvm_type, :user
set :rails_env, 'production'
set :use_sudo, false
set :keep_releases, 3
set :ec2_server, 'bzlabs.org'
set :port, 2222
set :symlinks, %w(config/database.yml config/unicorn.rb)

role :web, "#{ec2_server}"                   # Your HTTP server, Apache/etc
role :app, "#{ec2_server}"                   # This may be the same as your `Web` server
role :db,  "#{ec2_server}", :primary => true # This is where Rails migrations will run

# if you want to clean up old releases on each deploy uncomment this:
#before 'deploy:assets:precompile', 'deploy:symlink_shared'
after 'deploy:symlink_shared', 'deploy:rake_tasks'
after 'deploy:rake_tasks', 'nginx:config'
after 'nginx:config', 'nginx:reload'
after 'deploy', 'deploy:symlink_shared'
after 'deploy', 'deploy:cleanup'

namespace :deploy do
  %w(start stop restart).each do |action|
    #task(action) { run "cd #{current_path} && script/unicorn #{action}" }
  end

  task :symlink_shared, :except => { :no_release => true } do
    run(symlinks.map {|link| "ln -nfs #{shared_path}/#{link} #{release_path}/#{link}"}.join(' && '))
  end

  task :rake_tasks do
    run "cd #{release_path} && RAILS_ENV=production bundle exec rake db:migrate db:seed"
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
