

#Restore database, you must use vagrant for this part

unless File.exists?("#{node[:magento][:dir]}/installed_code.flag")

  execute "cp -R /vagrant/backup/source #{node[:magento][:dir]}" do
     creates node[:magento][:dir]
     group node[:webserver][:unix_user]
     user node[:webserver][:unix_user]  
  end 

  execute "chmod -R 777 #{node[:magento][:dir]}" do
    action :run
  end

  execute "touch #{node[:magento][:dir]}/installed_code.flag" do
  end
end

#Create a neww database (delete existing if exist)
#TODO use database provider https://github.com/opscode-cookbooks/database
execute "mysql -u #{node[:mysql][:db][:username]} -p#{node[:mysql][:db][:password]} -e'DROP DATABASE IF EXISTS #{node[:mysql][:db][:database]}'" do
end  

execute "create #{node[:mysql][:db][:database]} database" do
  command "mysql -u #{node[:mysql][:db][:username]} -p#{node[:mysql][:db][:password]} -e'CREATE DATABASE #{node[:mysql][:db][:database]}'"
end

bash "load magento database" do
  cwd "/vagrant/backup"
  code <<-EOH
    mysql -u #{node[:mysql][:db][:username]}\
          -p#{node[:mysql][:db][:password]}\
          #{node[:mysql][:db][:database]}\
          < *.sql
    EOH
end

config = {
  'username' => node[:mysql][:db][:username],
  'password' => node[:mysql][:db][:password],
  'dbname' => node[:mysql][:db][:database],
  'host' => 'localhost',
}

config.each do |key, value|
  execute "update value for #{key}" do
    cwd node[:magento][:dir]
    command "sed -i 's/<#{key}><!\\[CDATA\\[.*\\]\\]><\\/#{key}>/<#{key}><![CDATA[#{value}]]><\\/#{key}>/g' app/etc/local.xml"
    group node[:webserver][:unix_user]
    user node[:webserver][:unix_user]  
  end
end

execute "touch #{node[:magento][:dir]}/installed.flag" do
end

