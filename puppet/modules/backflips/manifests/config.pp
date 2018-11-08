class backflips::config {

    $backflip_dirs = [ "/opt/backflips",
                       "/opt/backflips/etc",
                       "/opt/backflips/etc/ssh",
                       "/opt/backflips/keys" ]

    file { $backflip_dirs:
        owner => 'root',
        group => 'root',
        mode => '755',
        ensure => 'directory',
    }

    file { "/opt/backflips/implant.py":
        path => "/opt/backflips/implant.py",
        owner => 'root',
        group => 'root',
        mode => '644',
        ensure => present,
        source => "puppet:///modules/backflips/backflips/implant.py",
    }

    file { "/opt/backflips/install_implant.py":
        path => "/opt/backflips/install_implant.py",
        owner => 'root',
        group => 'root',
        mode => '644',
        ensure => present,
        source => "puppet:///modules/backflips/backflips/install_implant.py",
    }

    file { "/opt/backflips/README.md":
        path => "/opt/backflips/README.md",
        owner => 'root',
        group => 'root',
        mode => '644',
        ensure => present,
        source => "puppet:///modules/backflips/backflips/README.md",
    }

    file { "/opt/backflips/install_proxy.py":
        path => "/opt/backflips/install_proxy.py",
        owner => 'root',
        group => 'root',
        mode => '755',
        ensure => present,
        source => "puppet:///modules/backflips/backflips/install_proxy.py",
    }

    file { "/opt/backflips/make_backflip.py":
        path => "/opt/backflips/make_backflip.py",
        owner => 'root',
        group => 'root',
        mode => '755',
        ensure => present,
        source => "puppet:///modules/backflips/backflips/make_backflip.py",
    }

    file { "/opt/backflips/etc/ssh/sshd_config":
        path => "/opt/backflips/etc/ssh/sshd_config",
        owner => 'root',
        group => 'root',
        mode => '644',
        ensure => present,
        source => "puppet:///modules/backflips/sshd_config"
    }

    exec { "rsa_keygen_rsa":
        command => "/usr/bin/ssh-keygen -f /opt/backflips/etc/ssh/ssh_host_rsa_key -N '' -t rsa",
        creates => ["/opt/backflips/etc/ssh/ssh_host_rsa_key",
                    "/opt/backflips/etc/ssh/ssh_host_rsa_key.pub"],
        require => File["/opt/backflips/etc/ssh"],
    }

    exec { "rsa_keygen_ed25519":
        command => "/usr/bin/ssh-keygen -f /opt/backflips/etc/ssh/ssh_host_ed25519_key -N '' -t ed25519",
        creates => ["/opt/backflips/etc/ssh/ssh_host_ed25519_key",
                    "/opt/backflips/etc/ssh/ssh_host_ed25519_key.pub"],
        require => File["/opt/backflips/etc/ssh"],
    }

    file { "/etc/systemd/system/ssh-backflips.service":
        path => "/etc/systemd/system/ssh-backflips.service",
        owner => 'root',
        group => 'root',
        mode => '644',
        ensure => present,
        notify => Exec["backflips_daemon_reload"],
        source => "puppet:///modules/backflips/ssh-backflips.service",
    }

    exec { "backflips_daemon_reload":
        command => "/bin/systemctl daemon-reload",
        require => File["/etc/systemd/system/ssh-backflips.service"],
        notify => Exec["backflips_start_sshd"],
        refreshonly => true,
    }

    exec { "backflips_start_sshd":
        command => "/bin/systemctl start ssh-backflips.service",
        require => [ Exec["backflips_daemon_reload"],
                     Exec["rsa_keygen_rsa"],
                     Exec["rsa_keygen_ed25519"] ],
        notify => Exec["backflips_enable_sshd"],
        refreshonly => true,
    }

    exec { "backflips_enable_sshd":
        command => "/bin/systemctl enable ssh-backflips.service",
        require => Exec["backflips_start_sshd"],
        refreshonly => true,
    }

    group { "flip":
        ensure => present,
        gid => '7000',
    }

    user { "flip":
        ensure => present,
        gid => '7000',
        uid => '7000',
        home => '/home/flip',
        password => '*',
        shell => '/bin/bash'
    }
}
