#!/bin/bash
if [ -f /etc/os-release ]
then
  ID=$(grep -e ID="centos" -e ID=ubuntu /etc/os-release)
fi

case "$ID" in
  'ID="centos"')
    yum install -y ruby ansible
    cp -f /opt/scripts/centos7_sshd_config /etc/ssh/sshd_config
    service sshd restart
    ;;
  'ID=ubuntu')
    apt install -y ruby ansible
    ;;
  *)
    yum install -y ruby ansible 
    cp -f /opt/scripts/cent6_sshd_config /etc/ssh/sshd_config
    service sshd restart
    ;;
esac


