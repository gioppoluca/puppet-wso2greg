# Class: wso2greg
#
# This module manages wso2greg
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class wso2greg (
  $db_type        = $wso2greg::params::db_type,
  $db_host        = $wso2greg::params::db_host,
  $db_name        = $wso2greg::params::db_name,
  $db_user        = $wso2greg::params::db_user,
  $db_password    = $wso2greg::params::db_password,
  $db_tag         = $wso2greg::params::db_tag,
  $product_name   = $wso2greg::params::product_name,
  $download_site  = $wso2greg::params::download_site,
  $admin_password = $wso2greg::params::admin_password,
  $is_remote      = $wso2greg::params::is_remote,
  $version        = '4.5.3',) inherits wso2greg::params {
  # service status
  if !($version in ['4.5.1', '4.5.2', '4.5.3']) {
    fail("\"${version}\" is not a supported version value")
  }
  $archive = "$product_name-$version.zip"
  $dir_bin = "/opt/${product_name}-${version}/bin/"

  exec { "get-greg-$version":
    cwd     => '/opt',
    command => "/usr/bin/wget ${download_site}${archive}",
    creates => "/opt/${archive}",
  }

  exec { "unpack-greg-$version":
    cwd       => '/opt',
    command   => "/usr/bin/unzip ${archive}",
    creates   => "/opt/${product_name}-$version",
    subscribe => Exec["get-greg-$version"],
    require   => Package['unzip'],
  }

  case $db_type {
    undef   : {
      # Use default H2 database
    }
    h2      : {
      # Use default H2 database
    }
    mysql   : {
      # we'll need a DB and a user for the local and config stuff
      @@mysql::db { $db_name:
        user     => $db_user,
        password => $db_password,
        host     => $::fqdn,
        grant    => ['all'],
        tag      => $db_tag,
      #    unless   => '/usr/bin/mysql -h ${db_host} -u ${db_user} -p${db_password} -NBe "show databases"',
      }

      file { "/opt/${product_name}-$version/repository/components/lib/mysql-connector-java-5.1.22-bin.jar":
        source  => "puppet:///modules/wso2greg/mysql-connector-java-5.1.22-bin.jar",
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        require => Exec["unpack-greg-$version"],
        before  => File["/opt/${product_name}-$version/bin/wso2server.sh"],
      }

      file { "/opt/${product_name}-$version/repository/conf/datasources/master-datasources.xml":
        content => template("wso2greg/${version}/master-datasources.xml.erb"),
        owner   => 'root',
        group   => 'root',
        mode    => 0644,
        require => Exec["unpack-greg-$version"],
        before  => File["/opt/${product_name}-$version/bin/wso2server.sh"],
      }

    }
    default : {
      fail('currently only mysql and h2 is supported - please raise a bug on github')
    }
  }

  file { "/opt/${product_name}-$version/repository/conf/registry.xml":
    content => template("wso2greg/${version}/registry.xml.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-greg-$version"],
  }

  file { "/opt/${product_name}-$version/repository/conf/user-mgt.xml":
    content => template("wso2greg/${version}/user-mgt.xml.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-greg-$version"],
  }

  file { "/opt/${product_name}-$version/repository/conf/axis2/axis2.xml":
    content => template("wso2greg/${version}/axis2.xml.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-greg-$version"],
  }

  file { "/opt/${product_name}-$version/bin/wso2server.sh":
    owner   => 'root',
    group   => 'root',
    mode    => 0744,
    require => Exec["unpack-greg-$version"],
  }

  exec { "setup-wso2greg":
    cwd         => "/opt/${product_name}-${version}/bin/",
    path        => "/opt/${product_name}-${version}/bin/:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
    environment => ["JAVA_HOME=/usr/java/default",],
    command     => "wso2server.sh -Dsetup",
    creates     => "/opt/${product_name}-$version/repository/logs/wso2carbon.log",
    unless      => "/usr/bin/test -s /opt/${product_name}-$version/repository/logs/wso2carbon.log",
    onlyif      => "/usr/bin/mysql -h ${db_host} -u ${db_user} -p${db_password} -e\"show databases\"|grep -q ${db_name}",
    logoutput   => true,
    require     => [
      File["/opt/${product_name}-$version/bin/wso2server.sh"],
      File["/opt/${product_name}-$version/repository/conf/user-mgt.xml"],
      File["/opt/${product_name}-$version/repository/conf/registry.xml"],
      File["/opt/${product_name}-$version/repository/conf/axis2/axis2.xml"],
      ],
  }

  file { "/etc/init.d/${product_name}":
    ensure => link,
    owner  => 'root',
    group  => 'root',
    target => "/opt/${product_name}-$version/bin/wso2server.sh",
  }

}
