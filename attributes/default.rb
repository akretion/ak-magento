#package
default[:ak_tools][:apt_packages] += %w[
zip
bzip2
php5-curl
php5-gd
bzr
] 


#Choose the magento version and the demo version
default[:magento][:magento_version]       = "1.7.0.2"
default[:magento][:magento_get_url]     = {
    "1.7.0.2" => "http://www.magentocommerce.com/downloads/assets/1.7.0.2/magento-1.7.0.2.tar.bz2",
}
default[:magento][:demo_version]          = false #"1.6.1.0" # set to False if you don't want to install demo data
default[:magento][:demo_get_url] = {
    "1.6.1.0"=> "http://www.magentocommerce.com/downloads/assets/1.6.1.0/magento-sample-data-1.6.1.0.tar.bz2",
}

#Magento configuration
default[:magento][:dir_www]               = "/var/www"
default[:magento][:dir_name]              = "magento"
default[:magento][:dir]                   = magento[:dir_www] + '/'+ magento[:dir_name]
default[:magento][:admin][:user]          = "admin"
default[:magento][:admin][:password]      = "admin25"
default[:magento][:port]                  = 8100
default[:magento][:url]                   = false
default[:magento][:previous_url]          = magento[:url]
default[:magento][:connector_branch]      = "http://bazaar.launchpad.net/branch/magentoerpconnect/magento-module-oerp6.x-stable"

#mysql configuration
default[:mysql][:db][:database]           = "magento"


#
default[:magento][:restor]                = false #restor an existing db instead of creating a new one

