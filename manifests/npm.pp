class nodejs::npm($user) {

  $NPM_PATH = '/usr/local/src/npm'
  $NPM_REPO = 'git://github.com/isaacs/npm.git'
  
  case $operatingsystem {
    Ubuntu,Debian: {
      if ! defined(Package['git-core'])             { package { 'git-core':             ensure => installed } }
    }
    default: {
      if ! defined(Package['git'])             { package { 'git':             ensure => installed } }
    }
  }
  
  exec { 'npm-git-clone':
      command => "git clone ${NPM_REPO} ${NPM_PATH}"
    , path    => ['/usr/bin']
    , creates => "${NPM_PATH}/.git/HEAD"
  }
  
  exec { "make_npm":
    cwd     => $NPM_PATH,
    command => "make install",
    require => [Exec['npm-git-clone'], Package['build-essential']],
    creates => "/usr/local/bin/npm",
    timeout => 0,
    path    => ["/usr/bin/","/bin/", "/usr/local/bin"],
  }
    
}
