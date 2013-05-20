# puppet-ipset

## Overview

Manage IP sets in the Linux kernel. Support in Red Hat Enterprise Linux has
been introduced in the RHEL 6.2 kernel (run `modinfo ip_set` to check).

* `ipset` : Main definition to create and manage IP sets.
* `ipset::iptables` : Definition to manage IP set related iptables rules.
* `ipset::base` : Base class for the common parts.
* `ipset::params` : Base class for distribution specific parameters.

Once you have your IP sets in place, you'll want to manage iptables rules which
make use of those IP sets.

This module is mostly a hack. The proper way to implementing IP sets would be
to create a clean system service script which would be run before iptables.

## Examples

Create a new `my_blacklist` IP set from a custom file :

    file { '/path/to/my_blacklist.txt': content => "10.0.0.1\n10.0.0.2\n" }
    ipset { 'my_blacklist':
      from_file => '/path/to/my_blacklist.txt',
    }

Insert an iptables REJECT rule on-the-fly which ses the `my_blacklist` IP set :

    ipset::iptables { 'my_blacklist':
      chain   => 'INPUT',
      options => '-p tcp',
      target  => 'REJECT',
    }

Similar, but logging 80/tcp traffic from the raw table's PREROUTING chain :

    ipset::iptables { 'my_blacklist-log':
      table   => 'raw',
      chain   => 'PREROUTING',
      ipset   => 'my_blacklist',
      options => '-p tcp --dport 80',
      target  => 'LOG --log-prefix "MyList: "',
    }

