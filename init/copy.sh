#! /bin/sh

copy_out () {
  mkdir -p /mnt/hgfs/set/${UTAGE}$1
  rmdir    /mnt/hgfs/set/${UTAGE}$1
  cp  $1   /mnt/hgfs/set/${UTAGE}$1
}

copy_out /etc/ssh/sshd_config
copy_out /etc/hosts
copy_out /etc/network/interfaces 
copy_out /etc/sysconfig/network-scripts/ifcfg-eth0
copy_out /root/.ssh/authorized_keys
copy_out /home/7korobi/.ssh/authorized_keys



