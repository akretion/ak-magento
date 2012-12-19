#
# Cookbook Name:: magento
# Recipe:: default
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

execute "apt-get update" do
  command "apt-get update"
  action :run
end



group node[:magento][:unix_user] do
end
  
user node[:magento][:unix_user] do
  comment "Magento User"
  gid node[:magento][:unix_user]
  home "/home/#{node[:magento][:unix_user]}"
  supports :manage_home=>true
  shell "/bin/bash"
end

include_recipe "magento::lamp"
include_recipe "magento::phpmyadmin"
include_recipe "bzr::default"  

apt_packages = %w[zip bzip2 php5-curl php5-cli php5-gd]
apt_packages.each do |pack|
  package pack do
    action :install
    options "--force-yes"
  end
end
  
execute "chown #{node[:magento][:unix_user]} /var/www" do
end

#configure apache
unless `grep '#{node[:magento][:dir]}' /etc/apache2/apache2.conf`.size >0

  execute "ln -s ../mods-available/rewrite.load" do
    cwd "/etc/apache2/mods-enabled"
    action :run
    not_if "test -f /etc/apache2/mods-enabled/rewrite.load"
  end
  
  script "configure apache" do
    interpreter "ruby"
    user "root"
    group "root"
    code <<-EOH
    File.open("/etc/apache2/apache2.conf", 'a') do |file|
      file.puts("<Directory #{node[:magento][:dir]}>\nAllowOverride All\n</Directory>")
    end
    EOH
    not_if "grep '#{node[:magento][:dir]}' /etc/apache2/apache2.conf", :user => "root", :group => "root"
  end
  
  execute "/etc/init.d/apache2 restart" do
    action :run
  end
end



directory "/tmp/magento" do
  group node[:magento][:unix_user]
  owner node[:magento][:unix_user]
  mode "0755"
  action :create
end
  
unless File.exists?("#{node[:magento][:dir]}/installed_code.flag")
  
  directory "/tmp/magento/magento" do
     group node[:magento][:unix_user]
     owner node[:magento][:unix_user]    
     action :delete
     recursive true
  end
  
  if node[:magento][:download_folder][0..3] == "http"
    #http://www.magentocommerce.com/getmagento/1.5.0.1/magento-1.5.0.1.tar.bz2
    execute "wget #{node[:magento][:download_folder]}/magento-#{node[:magento][:magento_version]}.tar.bz2" do
      creates "/tmp/magento/magento-#{node[:magento][:magento_version]}.tar.bz2"
      cwd "/tmp/magento"
      action :run
      group node[:magento][:unix_user]
      user node[:magento][:unix_user]
    end
  else
    execute "cp #{node[:magento][:download_folder]}/magento-#{node[:magento][:magento_version]}.tar.bz2 ." do
      creates "/tmp/magento/magento-#{node[:magento][:magento_version]}.tar.bz2"
      cwd "/tmp/magento"
      action :run
      group node[:magento][:unix_user]
      user node[:magento][:unix_user]  
    end
  end
  
  execute "tar -jxvf /tmp/magento/magento-#{node[:magento][:magento_version]}.tar.bz2" do
    creates "/tmp/magento/magento"
    cwd "/tmp/magento"
    group node[:magento][:unix_user]
    user node[:magento][:unix_user]
  end

  
  execute "mv magento #{node[:magento][:dir]}" do
     creates "#{node[:magento][:dir]}"
     cwd "/tmp/magento"
     group node[:magento][:unix_user]
     user node[:magento][:unix_user]  
  end 

  execute "chmod -R 777 #{node[:magento][:dir]}" do
    action :run
  end

  execute "touch #{node[:magento][:dir]}/installed_code.flag" do
  end
end


unless File.exists?("#{node[:magento][:dir]}/installed_code_connector.flag")
  directory "/tmp/magento/magento-module" do
     group node[:magento][:unix_user]
     owner node[:magento][:unix_user]    
     action :delete
     recursive true
  end

  execute "su - #{node[:magento][:unix_user]} -c 'bzr branch --stacked #{node[:magento][:connector_branch]} /tmp/magento/magento-module; '" do
    creates "/tmp/magento/magento-module"
    cwd "/tmp/magento"
    user "root"
    action :run
  end
  
  execute "mv magento-module/Openlabs_OpenERPConnector-1.1.0/app/etc/modules/Openlabs_OpenERPConnector.xml #{node[:magento][:dir]}/app/etc/modules/Openlabs_OpenERPConnector.xml" do
     creates "#{node[:magento][:dir]}/app/etc/module/Openlabs_OpenERPConnector.xml"
     cwd "/tmp/magento"
     group node[:magento][:unix_user]
     user node[:magento][:unix_user]  
  end
  
  execute "mv magento-module/Openlabs_OpenERPConnector-1.1.0/Openlabs #{node[:magento][:dir]}/app/code/community" do
     creates "#{node[:magento][:dir]}/app/code/community/Openlabs"
     cwd "/tmp/magento"
     group node[:magento][:unix_user]
     user node[:magento][:unix_user]  
  end
  
  execute "touch #{node[:magento][:dir]}/installed_code_connector.flag" do
  end
end


unless File.exists?("#{node[:magento][:dir]}/installed.flag")
  
  if node[:magento][:install_db_from_scratch]
    include_recipe "magento::install_db"
  else
    include_recipe "magento::restor_db"
  end  
end


#This code should create some magento data/configuration but creating data in magento with sql or with api is not easy at all
unless true #File.exists?("#{node[:magento][:dir]}/installed_sql_script.flag")
  if node[:magento][:init_sql_script]
    node[:magento][:init_sql_script].each do |script|
      
      template "/tmp/magento/#{script}.sql" do
        path "/tmp/magento/#{script}.sql"
        source "#{srcipt}.sql.erb"
        group node[:magento][:unix_user]
        user node[:magento][:unix_user]  
        variables()
        notifies :run
      end
      
      execute "#{script}" do
        command "mysql -u #{node[:magento][:db][:username]} -p#{node[:magento][:db][:password]} #{node[:magento][:db][:database]} < /tmp/magento/#{script}"
        action :nothing
      end  
    end
    
    execute "touch #{node[:magento][:dir]}/installed_sql_script.flag" do
    end
  end
end


#Update url if necessary
node[:magento][:full_url] = "#{node[:magento][:base_url]}/#{node[:magento][:dir_name]}/"

unless node[:previous_magento_url] == node[:magento][:full_url]
  execute "mysql -u #{node[:magento][:db][:username]} -p#{node[:magento][:db][:password]} -e \"use #{node[:magento][:db][:database]}; UPDATE core_config_data SET value = '#{node[:magento][:full_url]}' WHERE path = 'web/unsecure/base_url' or path = 'web/secure/base_url';\" -E" do
  end
  execute "rm -rf #{node[:magento][:dir]}/var/cache" do
  end
end


