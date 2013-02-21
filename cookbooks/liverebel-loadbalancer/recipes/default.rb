include_recipe "openssl"
include_recipe "apt"
include_recipe "java"
include_recipe "liverebel-database-agent"
include_recipe "apache2"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"
include_recipe "mysql::server"
include_recipe "database::mysql"
include_recipe "python"
include_recipe "selenium::firefox"
include_recipe "selenium::chrome"
include_recipe "selenium::grid_hub"
include_recipe "selenium::grid_node"

apache_module "proxy_balancer" do
  conf true
end

execute "disable-default-site" do
  command "sudo a2dissite default"
  notifies :reload, resources(:service => "apache2"), :delayed
end

mysql_connection_info = {:host => "localhost", :username => "root", :password => node["mysql"]["server_root_password"]}

mysql_database "qa" do
  connection mysql_connection_info
  action :create
end

mysql_database_user "qa" do
  connection mysql_connection_info
  password node["mysql"]["server_user_password"]
  action :create
end

mysql_database_user "qa" do
  connection mysql_connection_info
  password node["mysql"]["server_user_password"]
  database_name "qa"
  host "%"
  privileges [:select,:update,:insert]
  action :grant
end
