
if node[:magento][:use_demo]
  directory "/tmp/magento/#{node[:magento][:demo_version]}" do
     group node[:magento][:unix_user]
     owner node[:magento][:unix_user]    
     action :delete
     recursive true
  end

  execute "wget #{node[:magento][:download_folder]}/#{node[:magento][:demo_version]}.tar.bz2" do
    creates "/tmp/magento/#{node[:magento][:demo_version]}.tar.bz2"
    cwd "/tmp/magento"
    action :run
    group node[:magento][:unix_user]
    user node[:magento][:unix_user]  
  end
  
  execute "tar -jxvf #{node[:magento][:demo_version]}.tar.bz2" do
    creates "/tmp/magento/#{node[:magento][:demo_version]}"
    cwd "/tmp/magento"
    group node[:magento][:unix_user]
    user node[:magento][:unix_user]
  end

  execute "mysql -u #{node[:magento][:db][:username]} -p#{node[:magento][:db][:password]} #{node[:magento][:db][:database]} < #{node[:magento][:demo_version]}/#{node[:magento][:demo_version]}.sql" do
    cwd "/tmp/magento"
  end  
  
  execute "mv #{node[:magento][:demo_version]}/media/* #{node[:magento][:dir]}/media" do
     cwd "/tmp/magento"
     group node[:magento][:unix_user]
     user node[:magento][:unix_user]  
  end
end

bash "magento-install-site" do
  cwd node[:magento][:dir]
  code <<-EOH
  php -f install.php -- \
  --license_agreement_accepted "yes" \
  --locale "fr_FR" \
  --timezone "Europe/Berlin" \
  --default_currency "EUR" \
  --db_host "#{node[:magento][:db][:host]}" \
  --db_name "#{node[:magento][:db][:database]}" \
  --db_user "#{node[:magento][:db][:username]}" \
  --db_pass "#{node[:magento][:db][:password]}" \
  --url "#{node[:magento][:base_url]}/#{node[:magento][:dir_name]}/" \
  --skip_url_validation \
  --use_rewrites "yes" \
  --use_secure "no" \
  --secure_base_url "" \
  --use_secure_admin "no" \
  --admin_firstname "Admin" \
  --admin_lastname "Admin" \
  --admin_email "admin@admin.com" \
  --admin_username "#{node[:magento][:admin][:user]}" \
  --admin_password "#{node[:magento][:admin][:password]}"
  touch #{node[:magento][:dir]}/installed.flag
  EOH
end

directory "#{node[:magento][:dir]}/backup" do
  group node[:magento][:unix_user]
  owner node[:magento][:unix_user]
  mode "0755"
  action :create
end

execute "mysqldump -u #{node[:magento][:db][:username]} -p#{node[:magento][:db][:password]} #{node[:magento][:db][:database]} > #{node[:magento][:dir]}/backup/magento-#{node[:magento][:magento_version]}.sql" do
end