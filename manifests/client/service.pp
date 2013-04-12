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

  # Bootstrap ldap user/group cache
  exec { '/usr/sbin/nss_updatedb ldap':
    creates => '/var/lib/misc/passwd.db',
    cwd => '/var/lib/misc',
    user => root,
    group => root,
    require => [ Class['ldap::client::base'], File['/etc/libnss-ldap.conf'], Package['nss-updatedb'] ]
    ## FIXME: Debian/Ubuntu
  }

  # Maintain ldap user/group cache
  cron { 'nss-updatedb':
    ensure => present,
    command => '/usr/sbin/nss_updatedb ldap',
    user => root,
    hour => '*',
    minute => '*/10'
  }
}
