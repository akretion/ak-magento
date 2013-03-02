
#Create a neww database (delete existing if exist)
#TODO use database provider https://github.com/opscode-cookbooks/database
execute "mysql -u #{node[:mysql][:db][:username]} -p#{node[:mysql][:db][:password]} -e'DROP DATABASE IF EXISTS #{node[:mysql][:db][:database]}'" do
end  

execute "create #{node[:mysql][:db][:database]} database" do
  command "mysql -u #{node[:mysql][:db][:username]} -p#{node[:mysql][:db][:password]} -e'CREATE DATABASE #{node[:mysql][:db][:database]}'"
end


#Install demo data if necessary
if node[:magento][:demo_version]
  remote_file "#{Chef::Config[:file_cache_path]}/demo_data.tar.bz2" do
    source node[:magento][:demo_get_url][node[:magento][:demo_version]] 
    mode "0644"
    group node[:webserver][:unix_user]
    user node[:webserver][:unix_user]  
  end

  bash "load magento sample data" do
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
    tar -jxvf #{Chef::Config[:file_cache_path]}/demo_data.tar.bz2    
    mysql -u #{node[:mysql][:db][:username]}\
          -p#{node[:mysql][:db][:password]}\
          #{node[:mysql][:db][:database]}\
          < magento-sample-data-*/magento_sample_data*.sql
    mv magento-sample-data-*/media/* #{node[:magento][:dir]}/media
    chmod -R 777 #{node[:magento][:dir]}/media
    EOH
  end
end

#Launch magento installer
bash "magento-install-site" do
  cwd node[:magento][:dir]
  code <<-EOH
  php -f install.php -- \
  --license_agreement_accepted yes \
  --locale "fr_FR" \
  --timezone "Europe/Berlin" \
  --default_currency "EUR" \
  --db_host "#{node[:mysql][:db][:host]}" \
  --db_name "#{node[:mysql][:db][:database]}" \
  --db_user "#{node[:mysql][:db][:username]}" \
  --db_pass "#{node[:mysql][:db][:password]}" \
  --url "#{node[:magento][:url]}" \
  --skip_url_validation \
  --use_rewrites no \
  --use_secure no \
  --secure_base_url "" \
  --use_secure_admin no \
  --admin_firstname "Admin" \
  --admin_lastname "Admin" \
  --admin_email "admin@admin.com" \
  --admin_username "#{node[:magento][:admin][:user]}" \
  --admin_password "#{node[:magento][:admin][:password]}"
  touch #{node[:magento][:dir]}/installed.flag
  EOH
end

node[:previous_url] == node[:magento][:url]
