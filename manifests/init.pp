class nodejs($user) {

  $node_ver = "v0.6.7"
  $node_tar = "node-$node_ver.tar.gz"

  if ! defined(Package['openssl'])              { package { 'openssl':              ensure => 'installed' } }
  if ! defined(Package['libcurl4-openssl-dev']) { package { 'libcurl4-openssl-dev': ensure => 'installed' } }
  if ! defined(Package['build-essential'])      { package { 'build-essential':      ensure => 'installed' } }

  file { "/tmp/$node_tar":
      source => "puppet:///modules/nodejs/$node_tar"
    , ensure => "present"
  }

  exec { "extract_node":
      command => "tar -xzf $node_tar"
    , cwd => "/tmp"
    , creates => "/tmp/node-$node_ver"
    , require => File["/tmp/$node_tar"]
    , path    => ["/usr/bin/","/bin/"]
  }

  exec { "bash ./configure":
      alias => "configure_node"
    , cwd => "/tmp/node-$node_ver"
    , require => [Exec["extract_node"], Package["openssl"], Package["libcurl4-openssl-dev"], Package["build-essential"]]
    , timeout => 0
    , creates => "/tmp/node-$node_ver/.lock-wscript"
    , path    => ["/usr/bin/","/bin/"]
  }

  file { "/tmp/node-$node_ver":
      ensure => "directory"
    , require => Exec["configure_node"]
  }

  exec { "make_node":
      command => "make"
    , cwd => "/tmp/node-$node_ver"
    , require => Exec["configure_node"]
    , timeout => 0
    , creates	=> "/tmp/node-$node_ver/tools/js2c.pyc"
    , path    => ["/usr/bin/","/bin/"]
  }

  exec { "install_node":
      command => "make install"
    , cwd     => "/tmp/node-$node_ver"
    , require => Exec["make_node"]
    , timeout => 0
    , path    => ["/usr/bin/","/bin/"]
    , creates => '/usr/local/bin/node'
    , before  => Class['nodejs::npm']
  }
  
  class {"nodejs::npm": 
      user    => $user
  }
  
}

