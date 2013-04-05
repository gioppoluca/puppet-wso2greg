# === Class: moodle::params
#
#  The moodle configuration settings idiosyncratic to different operating
#  systems.
#
# === Parameters
#
# None
#
# === Examples
#
# None
#
# === Authors
#
# Lucsa Gioppo <gioppoluca@libero.it>
#
# === Copyright
#
# Copyright 2012 Luca Gioppo
#
class wso2greg::params {
$db_type            = "h2"
  $db_host            = "wso2mysql.$::domain"
  $db_name            = 'odaigreg'
  $db_user            = 'odaiagreg'
  $db_password        = 'odaigreg1'
  $db_tag        = 'greg_db'
  $port_offset        = 0
  $download_site      = 'http://dist.wso2.org/products/governance-registry/'
  $product_name       = 'wso2greg'
  $admin_password       = 'odaiadmin1'
  
}
