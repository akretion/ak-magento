#Version available "1.4.1.1" "1.5.0.1" "1.5.1.1" "1.6.1.0"
default[:magento][:magento_version]       = "1.6.1.0"
default[:magento][:dir_www]               = "/var/www"
default[:magento][:dir_name]              = "magento"
default[:magento][:dir]                   = default[:magento][:dir_www] + '/'+ default[:magento][:dir_name]
default[:magento][:db][:host]             = "localhost"
default[:magento][:db][:database]         = "magento"
default[:magento][:db][:username]         = "mag_user"
default[:magento][:db][:password]         = "admin25"
default[:magento][:admin][:user]          = "admin"
default[:magento][:admin][:password]      = "admin25"
default[:magento][:unix_user]             = "magento"
default[:magento][:base_url]              = "http://akretion_vm"
default[:magento][:download_folder]       = "https://s3.amazonaws.com/akretioncloud/magento_download"
default[:magento][:connector_branch]      = "lp:~mohammed-nahhas/magentoerpconnect/magento-module-dev"

default[:lamp][:mysql_root_password]      = "admin25"

default[:magento][:install_db_from_scratch] = true
default[:magento][:use_demo]              = true
default[:magento][:demo_version]          = 'magento-sample-original'

default[:magento][:init_sql_script]       = false#['french_taxe']
