include_recipe 'apt'

apt_repository 'brightbox-ruby-ng' do
  action       :add
  uri          'http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu'
  distribution node['lsb']['codename']
  components   ['main']
  keyserver    'keyserver.ubuntu.com'
  key          'C3173AA6'
end

apt_package 'build-essential'
apt_package 'ruby2.1'
apt_package 'ruby2.1-dev'
apt_package 'git'
apt_package 'libmysqlclient-dev'

gem_package 'bundler' do
  version node[:posso][:bundler_version]
  gem_binary '/usr/bin/gem'
end
gem_package 'thin' do
  version node[:posso][:thin_version]
  gem_binary '/usr/bin/gem'
end

execute 'install thin' do
  command 'thin install'
  not_if do ::File.exists?('/etc/thin') end
end

template '/etc/thin/posso.yml' do
  source 'posso.yml.erb'
  mode '00644'
  variables({ rails_env: node[:posso][:rails_env] })
end

include_recipe 'nodejs::nodejs_from_binary'
include_recipe 'nodejs::npm'

nodejs_npm 'bower' do
  version node[:posso][:bower_version]
end

nodejs_npm 'phantomjs' do
  version node[:posso][:phantomjs_version]
end

include_recipe 'nginx'

template '/etc/nginx/sites-available/posso.com' do
  source 'posso.com.erb'
  mode '00644'
  variables({ restricted: node[:posso][:rails_env] != 'development' })
end

link '/etc/nginx/sites-enabled/posso.com' do
  to '/etc/nginx/sites-available/posso.com'
end

htpasswd '/etc/nginx/.htpasswd' do
  user 'setefi'
  password 'setefi'
end

directory '/var/www/posso' do
  owner 'www-data'
  group 'www-data'
  mode '2775'
  recursive true
  action :create
end

directory '/var/log/thin' do
  owner 'www-data'
  group 'www-data'
  mode '2775'
  action :create
end

execute 'install chef-dk' do
  command 'curl https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.3.6-1_amd64.deb -L -O && dpkg -i chefdk_0.3.6-1_amd64.deb'
  not_if 'command -v chef >/dev/null 2>&1 && chef verify'
end

directory "/opt/aws/cloudwatch" do
  recursive true
end

remote_file "/opt/aws/cloudwatch/awslogs-agent-setup.py" do
  source "https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py"
  mode "0755"
end

template "/tmp/cwlogs.cfg" do
  source "cwlogs.cfg.erb"
  owner "root"
  group "root"
  mode 0644
  variables({ rails_env: node[:posso][:rails_env] })
end
 
execute "Install CloudWatch Logs agent" do
  command "/opt/aws/cloudwatch/awslogs-agent-setup.py -n -r eu-central-1 -c /tmp/cwlogs.cfg"
  not_if { system "pgrep -f aws-logs-agent-setup" }
end

