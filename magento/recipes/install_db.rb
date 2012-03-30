
if node[:magento][:use_demo]
  directory "/tmp/magento/#{node[:magento][:demo_version]}" do
     group node[:magento][:unix_user]
     owner node[:magento][:unix_user]
     action :delete
     recursive true
  end

  if node[:magento][:demo_version] == 'defaults'
    if node[:magento][:magento_version] >= "1.6.1.0"
        node[:magento][:demo_version]="magento-sample-1.6.1.0"
    else
        node[:magento][:demo_version]="magento-sample-original"
    end
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

  execute "mysql -u #{node[:magento][:db][:username]} -p#{node[:magento][:db][:password]} -e'DROP DATABASE IF EXISTS #{node[:magento][:db][:database]}'" do
    cwd "/tmp/magento"
  end  
  
  execute "create #{node[:magento][:db][:database]} database" do
    command "mysql -u #{node[:magento][:db][:username]} -p#{node[:magento][:db][:password]} -e'CREATE DATABASE #{node[:magento][:db][:database]}'"
  end

  execute "mysql -u #{node[:magento][:db][:username]} -p#{node[:magento][:db][:password]} #{node[:magento][:db][:database]} < #{node[:magento][:demo_version]}/#{node[:magento][:demo_version]}.sql" do
    cwd "/tmp/magento"
  end  
  
  directory "#{node[:magento][:dir]}/media" do
     group node[:magento][:unix_user]
     owner node[:magento][:unix_user]
     action :delete
     recursive true
  end

  execute "mv #{node[:magento][:demo_version]}/media/* #{node[:magento][:dir]}/media" do
     cwd "/tmp/magento"
     group node[:magento][:unix_user]
     user node[:magento][:unix_user]  
  end

  execute "chmod 777 #{node[:magento][:dir]}/media" do
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
  --url "#{node[:ec2] && node[:ec2][:public_hostname] || node[:magento][:base_url]}/#{node[:magento][:dir_name]}" \
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
