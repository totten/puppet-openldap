# Class: ldap::client::service
#
# This module manages LDAP Client service management
#
# Parameters:
#
# There are no default parameters for this class.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# This class file is not called directly
class ldap::client::service(
  $ensure
) {

  # TODO: Need to add a translation between passed 'ensure' to this service
  # state

  service { 'nscd':
    ensure     => 'stopped',
    enable     => false,
    hasrestart => true,
    hasstatus  => true,
  }

  file { '/usr/local/sbin/nss_updatedb_quiet':
     owner     => root,
     group     => root,
     mode      => 755,
     source    => 'puppet:///ldap/nss_updatedb_quiet',
  }

  # Bootstrap ldap user/group cache
  exec { '/usr/local/sbin/nss_updatedb_quiet':
    creates => '/var/lib/misc/passwd.db',
    cwd => '/var/lib/misc',
    user => root,
    group => root,
    require => [ Class['ldap::client::base'], File['/etc/libnss-ldap.conf'], Package['nss-updatedb'], File['/usr/local/sbin/nss_updatedb_quiet'] ]
    ## FIXME: Debian/Ubuntu
  }

  # Maintain ldap user/group cache
  cron { 'nss-updatedb':
    ensure => present,
    command => '/usr/local/sbin/nss_updatedb_quiet',
    user => root,
    hour => '*',
    minute => '*/10'
  }
}
