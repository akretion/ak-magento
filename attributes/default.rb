#Version available : "1.4.1.1" "1.5.0.1" "1.5.1.0" "1.6.1.0"

#version 1.3.2.4 is also available but you should use the version 5.2 of php or install the magento under an ubuntu 8.04 -- 9.04
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
default[:magento][:base_url]              = "http://akretionvm"
default[:magento][:full_url]              = "#{magento[:base_url]}/#{magento[:dir_name]}/"
default[:magento][:previous_full_url]     = magento[:full_url]
default[:magento][:download_folder]       = "http://s3.amazonaws.com/akretioncloud/magento_download"
default[:magento][:connector_branch]      = "lp:magentoerpconnect/magento-module-oerp6.x-stable"
default[:magento][:demo_type]             = "demo-normal"

default[:lamp][:mysql_root_password]      = "admin25"

default[:magento][:install_db_from_scratch] = true
default[:magento][:use_demo]              = true
#Demo option : "defaults"
#defaults option will automatically install the version of magento-sample-1.6.1.0 or magento-sample-original regarding the version chosen
default[:magento][:demo_version]          = 'defaults'

default[:magento][:init_sql_script]       = false#['french_taxe']
