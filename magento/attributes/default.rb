default[:magento][:magento_version]       = "1.5.0.1"
default[:magento][:dir_www]               = "/var/www"
default[:magento][:dir_name]              = "magento-15"
default[:magento][:dir]                   = default[:magento][:dir_www] + '/'+ default[:magento][:dir_name]
default[:magento][:db][:host]             = "localhost"
default[:magento][:db][:database]         = "magento-15"
default[:magento][:db][:username]         = "mag_user"
default[:magento][:db][:password]         = "admin25"
default[:magento][:admin][:user]          = "admin"
default[:magento][:admin][:password]      = "admin25"
default[:magento][:unix_user]             = "magento"
default[:magento][:base_url]              = "http://192.168.56.101"
default[:magento][:download_folder]       = "https://s3.amazonaws.com/akretioncloud/magento_download"

default[:lamp][:mysql_root_password]      = "admin25"

default[:magento][:install_db_from_scratch] = true
default[:magento][:use_demo]              = true
default[:magento][:demo_version]          = 'magento-sample-original'

default[:magento][:init_sql_script]       = false#['french_taxe']
