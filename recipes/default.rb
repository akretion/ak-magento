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
    node.default[:magento][:url] = node[:magento][:force_url]
else
    node.default[:magento][:url] = "http://localhost:#{node[:magento][:port]}"
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

unless File.exists?("#{node[:magento][:dir]}/installed.flag")
  if node[:magento][:restore]
    include_recipe "ak-magento::restore_env"
  else
   include_recipe "ak-magento::install_magento"
  end  
end

#Update url if necessary

unless node[:magento][:previous_url] == node[:magento][:url]
  execute "mysql -u #{node[:mysql][:db][:username]} -p#{node[:mysql][:db][:password]} -e \"use #{node[:mysql][:db][:database]}; UPDATE core_config_data SET value = '#{node[:magento][:url]}' WHERE path = 'web/unsecure/base_url' or path = 'web/secure/base_url';\" -E" do
  end
  execute "rm -rf #{node[:magento][:dir]}/var/cache" do
  end
end



