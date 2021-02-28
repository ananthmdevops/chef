config_dir = node['redis']['config_dir']
system_dir = node['redis']['system_dir']
log_dir = node['redis']['log_dir']
data_dir = node['redis']['data_dir']

# Configure Redis.
template "#{config_dir}/redis.conf" do
  source 'redis.conf.erb'
  owner 'root'
  group 'root'
  variables(
    'system_dir'=>system_dir,
    'log_dir'=>log_dir,
    'data_dir'=>data_dir
  )
  mode 0600
  backup false
  action 'create'
end

# Create empty PID file.
execute 'Create empty PID file' do
  command "touch #{system_dir}/process.pid"
  user 'root'
  group 'root'
  returns [0]
  action 'run'
  not_if do
    File.exists?"#{system_dir}/process.pid"
  end
end

# Configure Supervisor for Redis.
template '/etc/supervisord.d/redis.ini' do
  source 'supervisor.ini.erb'
  owner 'root'
  group 'root'
  variables(
    'config_dir'=>config_dir,
    'system_dir'=>system_dir
  )
  mode 0644
  backup false
  action 'create'
end
