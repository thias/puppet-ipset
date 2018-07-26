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
        $init_file = $::operatingsystemmajrelease ? {
            /(5|6)/ => 'init.ipset.service',        
            /(7)/   => "ipset.start-stop",
        }   
        $init_path = $::operatingsystemmajrelease ? {
            /(5|6)/ => '/etc/init.d/ipset',        
            /(7)/   => $startscript,
        }       
        $service_name = $::operatingsystemmajrelease ? {
            /(5|6)/ => 'ipset',        
            /(7)/   => 'ipset.service',
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

    file { '/etc/ipset':
      ensure => 'directory',
    }

    file { $init_path:
      ensure  => 'present',
      mode   => '0755',     
      source  => "puppet:///modules/ipset/$init_file",
      owner   => $user,
    }
    

    
  if ($::osfamily == 'RedHat') and ($operatingsystemrelease =~ /^7.*/  ) {
      file { '/usr/libexec/ipset':
      ensure => 'directory',
      } ->
      file { $service_file:
      ensure  => 'present',
      replace => 'yes',
      source  => 'puppet:///modules/ipset/ipset.service',
      owner   => $user,
    }   
  } 
  
    service { $service_name:
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => File["$service_file"],
    }


}

