include_recipe "apache2::default"

apt_packages = %w[mysql-server php5 php5-mysql]
apt_packages.each do |ap|
  package "#{ap}"
end

execute "assign-root-password" do
  command "/usr/bin/mysqladmin -u root password #{node[:lamp][:mysql_root_password]}"
  action :run
  only_if "/usr/bin/mysql -u root -e 'show databases;'"
end


  # execute "assign-root-password" do
  #   command "/usr/bin/mysqladmin -u root password #{node[:mysql][:server_root_password]}"
  #   action :run
  #   only_if "/usr/bin/mysql -u root -e 'show databases;'"
  # end
  

#Create mysql user

execute "mysql-install-mage-privileges" do
  command "/usr/bin/mysql -u root -p#{node[:lamp][:mysql_root_password]} -Dmysql -e \"GRANT ALL ON #{node[:magento][:db][:database]}. * TO '#{node[:magento][:db][:username]}'@'localhost' IDENTIFIED BY '#{node[:magento][:db][:password]}'; FLUSH PRIVILEGES;\" " 
  action :run
end
