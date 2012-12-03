# set :shared_children, shared_children << 'tmp/sockets'

# namespace :deploy do
#   desc "Start the application"
#   task :start, :roles => :app, :except => { :no_release => true } do
#     run "cd #{current_path} && RAILS_ENV=#{stage} bundle exec puma -b 'unix://#{shared_path}/sockets/puma.sock' -S #{shared_path}/sockets/puma.state --control 'unix://#{shared_path}/sockets/pumactl.sock' >> #{shared_path}/log/puma-#{stage}.log 2>&1 &", :pty => false
#   end

#   desc "Stop the application"
#   task :stop, :roles => :app, :except => { :no_release => true } do
#     run "cd #{current_path} && RAILS_ENV=#{stage} bundle exec pumactl -S #{shared_path}/sockets/puma.state stop"
#   end

#   desc "Restart the application"
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "cd #{current_path} && RAILS_ENV=#{stage} bundle exec pumactl -S #{shared_path}/sockets/puma.state restart"
#   end

#   desc "Status of the application"
#   task :status, :roles => :app, :except => { :no_release => true } do
#     run "cd #{current_path} && RAILS_ENV=#{stage} bundle exec pumactl -S #{shared_path}/sockets/puma.state stats"
#   end
# end


set :shared_children, shared_children << 'tmp/puma'
set_default(:puma_config) { "#{shared_path}/config/puma.rb" }
set_default(:puma_log) { "#{shared_path}/log/puma.log" }
namespace :puma do
  desc "Setup puma initializer and app configuration"
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "puma.rb.erb", "#{shared_path}/config/puma.rb"
    template "puma_init.erb", "/tmp/puma_init"
    template "puma_init_run.erb", "/tmp/puma_init_run"
    run "chmod +x /tmp/puma_init"
    run "chmod +x /tmp/puma_init_run"
    run "#{sudo} touch /etc/puma.conf"
    run "#{sudo} mv /tmp/puma_init /etc/init.d/puma_#{application}"
    run "#{sudo} mv /tmp/puma_init_run /usr/local/bin/run-puma"
  end
  after "deploy:setup", "unicorn:setup"

  %w[start stop restart].each do |command|
    desc "#{command} unicorn"
    task command, roles: :app do
      run "service puma_#{application} #{command}"
    end
    after "deploy:#{command}", "puma:#{command}"
  end
end