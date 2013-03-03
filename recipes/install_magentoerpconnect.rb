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


