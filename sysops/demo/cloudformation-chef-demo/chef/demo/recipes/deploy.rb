user 'deploy' do
  comment 'Deploy User'
  gid 'www-data'
  home '/home/deploy'
  shell '/bin/bash'
  supports :manage_home => true
  action [ :create, :manage ]
end

directory '/home/deploy/.ssh' do
  owner 'deploy'
  group 'www-data'
  mode 0755
  action :create
  not_if { File.exists? '/home/deploy/.ssh' }
end

cookbook_file '/home/deploy/.ssh/id_rsa' do
  source 'id_rsa'
  owner 'deploy'
  group 'www-data'
  mode 0600
  action :create
end

cookbook_file '/home/deploy/.ssh/id_rsa.pub' do
  source 'id_rsa.pub'
  owner 'deploy'
  group 'www-data'
  mode  0600
  action :create
end

cookbook_file '/home/deploy/.ssh/config' do
  source 'config'
  owner 'deploy'
  group 'www-data'
  mode 0600
  action :create
end

cookbook_file '/home/deploy/.ssh/authorized_keys' do
  source 'authorized_keys'
  owner 'deploy'
  group 'www-data'
  mode 0600
  action :create
end

sudo 'deploy' do
  user 'deploy'
  nopasswd  true
  commands  ['/usr/bin/chef-client', '/bin/chown -R deploy.www-data /var/www/posso/*', '/usr/sbin/service thin restart', '/usr/sbin/service nginx reload']
end
