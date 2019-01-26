#cloud-config

# vim:ft=yaml

# TODO
# Set the hostname and fqdn

timezone: Europe/London

locale: "en_GB.UTF-8"
# locale_configfile: /etc/default/locale

package_update:   true
package_upgrade:  true
package_reboot_if_required: true
packages:
  - ca-certificates
  - curl
  - openssl
  - unzip
  - wget

# Commands to run early in the boot process, on every boot
bootcmd:
  - echo 'my boot command 1'
  - echo 'my boot command 2'

# Commands to run at first boot
runcmd:
  - echo 'my first run command 1'  >> /var/log/runcmd.log
  - echo 'my first run command 2'  >> /var/log/runcmd.log

# Register host into dynamic inventory
cc_ready_cmd: [ sh, -c, 'echo cloud-init complete, doing something ...' ]

final_message: The system is finally up, after \$UPTIME seconds.
