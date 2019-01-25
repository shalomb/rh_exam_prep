#!/bin/bash

yum -y update
yum -y install epel-release
yum -y install vim git wget firewalld
systemctl start firewalld
systemctl enable firewalld


wget http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm
rpm -Uvh erlang-solutions-1.0-1.noarch.rpm
yum -y install erlang socat logrotate
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.7.9/rabbitmq-server-3.7.9-1.el7.noarch.rpm
rpm --import https://www.rabbitmq.com/rabbitmq-signing-key-public.asc
rpm -Uvh rabbitmq-server-3.7.9-1.el7.noarch.rpm
systemctl start rabbitmq-server
systemctl enable rabbitmq-server
wait 30
firewall-cmd --zone=public --permanent --add-port=4369/tcp
firewall-cmd --zone=public --permanent --add-port=25672/tcp
firewall-cmd --zone=public --permanent --add-port=5671-5672/tcp
firewall-cmd --zone=public --permanent --add-port=15672/tcp
firewall-cmd --zone=public --permanent --add-port=61613-61614/tcp
firewall-cmd --zone=public --permanent --add-port=1883/tcp
firewall-cmd --zone=public --permanent --add-port=8883/tcp

wait 5
firewall-cmd --reload
wait 10
setsebool -P nis_enabled 1
wait 30
rabbitmq-plugins enable rabbitmq_management
chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/