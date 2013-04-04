# wso2greg #

This is the wso2greg module. It manages the WSO2 Governance Registry component.

It install it by downloading it from a web source you have to provide: just download the zip file from the WSO2 site and place on a web accessible place.

As for now just 4.5.1 - .2 - .3 are supported and it is designed to use a MySQL DB as datasource.
The MySQL could be on a different machine so the exported resources is used.
If on the same machine just prepare the node with MySQL treating the stuff as an external resource


class mynode () {
  
  $repo_server = "http://your.site/your_path/"
  package { 'unzip': ensure => present, }

  # just need the client assuming the server is somewhere else
  package { 'mysql': ensure => present, }

  # in case you want to have the MySQL server in the same machine you have to add the part between --- MySQL ---
  # otherwise this code goes to the MySQL server node
  # --- MySQL ---
  
  class { 'mysql::server':
    config_hash => {
      root_password => 'your password',
      bind_address  => $::ipaddress,
    }
  }
  Mysql::Db <<| tag == 'greg_db' |>>
  
  # --- MySQL ---

  # REQUIREMENTS
  # Java
  # use your preferred module
  

  class { 'wso2greg':
    download_site	=> "${repo_server}",
    db_type			=>"mysql",
    db_tag			=>'greg_db',
    require       	=> [Class['opendai_java'], Package['unzip'], Package['mysql']]
  }
}