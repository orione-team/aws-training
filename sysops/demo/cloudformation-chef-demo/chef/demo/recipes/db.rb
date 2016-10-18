mysql_service 'default' do
  version node['mysql']['version']
  initial_root_password node['mysql']['root_password']
  action [:create, :start]
end

mysql2_chef_gem 'default' do
  action :install
end

connection_info = {
  host: 'localhost',
  username: 'root',
  password: node['mysql']['root_password'],
  socket: '/var/run/mysql-default/mysqld.sock'
}

mysql_database 'posso' do
  connection connection_info
  action :create
end

mysql_database_user 'posso' do
  connection connection_info
  database_name 'posso'
  password 'posso'
  privileges [:all]
  action :grant
end
