# Define: ipset
#
# Create and manage ipsets. You must pass one of $from_file, ... TODO, unless
# you are passing "ensure => absent" to remove the ipset.
#
# Parameters:
#  $from_file:
#    Create and manage the ipset from the content of a file. Default: none
#  $ipset_type:
#    The type of the ipset. Default: hash:ip
#  $ipset_create_options:
#    The create options of the ipset. Default: empty
#  $ipset_add_options:
#    The add options of the ipset elements. Default: empty
#
# Sample Usage:
#  file { '/path/to/my_blacklist.txt': content => "10.0.0.1\n10.0.0.2\n" }
#  ipset { 'my_blacklist':
#    from_file => '/path/to/my_blacklist.txt',
#  }
#
define ipset (
  $from_file = false,
  $ipset_type = 'hash:ip',
  $ipset_create_options = '',
  $ipset_add_options = '',
  $ensure = undef
) {

  # Even for "absent", since it requires the tool to work
  include ipset::base

  if $ensure == 'absent' {
    exec { "ipset destroy ${title}":
      onlyif  => "ipset list ${title} &>/dev/null",
      path    => [ '/sbin', '/usr/sbin', '/bin', '/usr/bin' ],
      require => Package['ipset'],
    }
  } else {

    # Run in the from_file mode (the only one implemented initially
    if $from_file {

      # We need two execs, one for when the set doesn't exist and the
      # other when the file changes. It's not possible to mix both
      # "unless" and "subscribe", as "unless" will prevent the
      # "subscribe" triggered runs from actually being executed.
      $command = "/usr/local/sbin/ipset_from_file -n ${title} -f ${from_file} -t \"${ipset_type}\" -c \"${ipset_create_options}\" -a \"${ipset_add_options}\""
      exec { "ipset-create-${name}":
        command   => $command,
        unless    => "ipset list ${title} >/dev/null",
        logoutput => false,
        require   => Package['ipset'],
        path      => [ '/sbin', '/usr/sbin', '/bin', '/usr/bin' ],
      }
      exec { "ipset-refresh-${name}":
        command     => $command,
        subscribe   => File[$from_file],
        refreshonly => true,
        logoutput   => false,
        require     => Package['ipset'],
        path        => [ '/sbin', '/usr/sbin', '/bin', '/usr/bin' ],
      }
    }

  }

}

