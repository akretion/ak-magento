
package "phpmyadmin" do
  action :install
end

unless File.exists?("/var/www/phpmyadmin")
  
  execute "ln -s /usr/share/phpmyadmin" do
    creates "/var/www/phpmyadmin"
    cwd "/var/www/"
    action :run
  end
  
  execute "/etc/init.d/apache2 restart" do
    action :run
  end
end
