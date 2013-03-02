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

include_recipe "ak-lnmp"

if node[:magento][:force_url]
    node[:magento][:url] = node[:magento][:force_url]
else
    node[:magento][:url] = "http://localhost:#{node[:magento][:port]}"
end

#Configure NGINX
template "/etc/nginx/sites-available/magento" do
  owner "root"
  group "root"
  mode 00777
  source "magento.erb"
  variables :port => node[:magento][:port], :directory => node[:magento][:dir]
  notifies :restart, "service[nginx]"
end

execute "enable magento website" do
  command "ln -s ../sites-available/magento magento"
  cwd "/etc/nginx/sites-enabled"
  group "root"
  user "root"
  action :run
  not_if {File.exist?("/etc/nginx/sites-enabled/magento")}
  notifies :restart, "service[nginx]"
end

#Install Magento code source
unless File.exists?("#{node[:magento][:dir]}/installed_code.flag")

  remote_file "#{Chef::Config[:file_cache_path]}/magento_source.tar.bz2" do
    source node[:magento][:magento_get_url][node[:magento][:magento_version]]
    group node[:webserver][:unix_user]
    owner node[:webserver][:unix_user]    
    mode "0644"
  end

  execute "tar -jxvf #{Chef::Config[:file_cache_path]}/magento_source.tar.bz2" do
     creates node[:magento][:dir]
     cwd node[:magento][:dir_www]
     group node[:webserver][:unix_user]
     user node[:webserver][:unix_user]  
  end 

  execute "chmod -R 777 #{node[:magento][:dir]}" do
    action :run
  end

  execute "touch #{node[:magento][:dir]}/installed_code.flag" do
  end
end

#install MagentoERPconnect extention
unless File.exists?("#{node[:magento][:dir]}/installed_code_connector.flag")

  execute "su - #{node[:webserver][:unix_user]} -c 'bzr branch --stacked #{node[:magento][:connector_branch]} magentoerpconnect; '" do
    creates "/home/#{node[:webserver][:unix_user]}/magentoerpconnect"
    cwd "/home/#{node[:webserver][:unix_user]}"
    user "root"
    action :run
  end
  
  execute "ln -s /home/#{node[:magento][:unix_user]}/magentoerpconnect/Openlabs_OpenERPConnector-1.1.0/app/etc/modules/Openlabs_OpenERPConnector.xml #{node[:magento][:dir]}/app/etc/modules/Openlabs_OpenERPConnector.xml" do
     creates "#{node[:magento][:dir]}/app/etc/module/Openlabs_OpenERPConnector.xml"
     group node[:webserver][:unix_user]
     user node[:webserver][:unix_user]  
  end
  
  execute "ln -s /home/#{node[:magento][:unix_user]}/magentoerpconnect/Openlabs_OpenERPConnector-1.1.0/Openlabs #{node[:magento][:dir]}/app/code/community" do
     creates "#{node[:magento][:dir]}/app/code/community/Openlabs"
     group node[:webserver][:unix_user]
     user node[:webserver][:unix_user]  
  end
  
  execute "touch #{node[:magento][:dir]}/installed_code_connector.flag" do
  end
end

unless File.exists?("#{node[:magento][:dir]}/installed.flag")
#  if node[:magento][:restor]
#    include_recipe "ak-magento::restor_db"
#  else
    include_recipe "ak-magento::install_db"
#  end  
end

#Update url if necessary

#unless node[:previous_url] == node[:magento][:url]
#  execute "mysql -u #{node[:magento][:db][:username]} -p#{node[:magento][:db][:password]} -e \"use #{node[:magento][:db][:database]}; UPDATE core_config_data SET value = '#{node[:magento][:url]}' WHERE path = 'web/unsecure/base_url' or path = 'web/secure/base_url';\" -E" do
#  end
#  execute "rm -rf #{node[:magento][:dir]}/var/cache" do
#  end
#end


