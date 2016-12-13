# Class: ipset::base
#
# Base class for ipset support. Not really useful on its own.
#
# Parameters:
#  none
#
# Sample Usage :
#  include ipset
#
class ipset::base inherits ipset::params {
  $startscript = "/usr/libexec/ipset/ipset.start-stop"
   
    case $::osfamily {
    'RedHat': {
        $service_file = $::operatingsystemmajrelease ? {
            /(5|6)/ => '/etc/init.d/ipset',        
            /(7)/   => "/etc/systemd/system/ipset.service",
        }
    }
  }
  # Main package
  package { $ipset::params::package:
    alias  => 'ipset',
    ensure => installed,
  }


 
  file { '/usr/local/sbin/ipset_from_file':
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/ipset_from_file",
  }

  if ($::osfamily == 'RedHat') and ($operatingsystemrelease =~ /^7.*/  ) {

    file { '/etc/ipset':
      ensure => 'directory',
    }

    file { $service_file:
      ensure  => 'present',
      replace => 'no',
      source  => 'puppet:///modules/ipset/ipset.service',
      owner   => $user,
    }

    file { $startscript:
      ensure  => 'present',
      replace => 'no',
      source  => 'puppet:///modules/ipset/ipset.start-stop',
      owner   => $user,
    }
    
    service { 'ipset.service':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  } 

}

