#!/bin/bash
env='prod'

sudo su
sudo yum -y update
sudo yum -y install wget rpm epel-release awscli ruby python

# wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie"  "http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jre-8u131-linux-x64.rpm"

# sudo yum -y localinstall jre-8u131-linux-x64.rpm
#preserve host name
#echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg

echo "manage_etc_hosts: true" >> /etc/cloud/cloud.cfg

# sudo rm -rf jre-8u131-linux-x64.rpm
sudo wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jre-8u151-linux-x64.tar.gz"
sudo tar -zxvf jre-8u*-linux-*.tar.gz
sudo mv jre1.8.*/ /usr/java
sudo update-alternatives --install /usr/bin/java java /usr/java/bin/java 2
wget http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
sudo rpm -ivh nginx-release-centos-7-0.el7.ngx.noarch.rpm
sudo yum install -y nginx
sudo rm -rf nginx-release-centos-7-0.el7.ngx.noarch.rpm
sudo service nginx start
sudo chkconfig nginx on

sudo yum install ntp -y
sudo timedatectl set-timezone Asia/Singapore
sudo systemctl enable ntpd
sudo systemctl disable chronyd
sudo systemctl start ntpd

cd /tmp/
wget https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py
chmod +x awslogs-agent-setup.py
pwd

echo "[general]
state_file = /var/awslogs/state/agent-state
 
[/var/log/nginx/error.log]

datetime_format = %Y/%m/%d %H:%M:%S
file = /var/log/nginx/error.log
buffer_duration = 5000
log_stream_name = NginxErrorLogs
initial_position = end_of_file
log_group_name = $env-APG-Web-API-logs

[/var/log/messages]
datetime_format = %Y/%m/%d %H:%M:%S
file = /var/log/messages
buffer_duration = 5000
log_stream_name = API-Syslogs
initial_position = end_of_file
log_group_name = $env-APG-Web-API-logs

[/var/log/APG-Web-API/logs/Debug.log]

datetime_format = %Y/%m/%d %H:%M:%S
file = /var/log/APG-Web-API/logs/Debug.log
buffer_duration = 5000
log_stream_name = API-Debuglogs
initial_position = end_of_file
log_group_name = $env-APG-Web-API-logs" >> /tmp/conf

sudo ./awslogs-agent-setup.py -c /tmp/conf -r ap-southeast-1 -n
sudo systemctl daemon-reload
sudo systemctl restart awslogs.service
sudo service awslogs start
sudo systemctl enable awslogs.service
sudo systemctl start awslogs.service
(crontab -l ; echo "* 3 * * * sudo systemctl restart awslogs.service --from-cron")| sudo crontab -

cd /tmp/
sudo yum install perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https perl-Digest-SHA -y
sudo yum install zip unzip -y
sudo curl http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip -O
sudo unzip CloudWatchMonitoringScripts-1.2.1.zip
sudo rm -f CloudWatchMonitoringScripts-1.2.1.zip
cd aws-scripts-mon

(crontab -l ; echo "*/2 * * * * /tmp/aws-scripts-mon/mon-put-instance-data.pl --mem-used-incl-cache-buff --mem-util --disk-space-util --disk-path=/ --from-cron")| sudo crontab -

cd /etc/pki/
sudo mkdir nginx
cd /etc/pki/nginx
sudo mkdir private

#
#
#SIEM Configuration 
#------------------
#We need to pass unique identifier for each server type 
#This is required to understand SIEM datasource
# Unique Identifier is "apgapi". 

#Encryption
#----------
# If rec_encrypt=0 is set to "rec_encrypt=1"
# encryption will be enabled between client and SIEM server

echo '##############
# Collector
##############
bookmark_dir=/var/lib/mcafee/bookmark
debug_level=info
log_path=/var/log/mcafee/siem_collector.log
sleep=5
throttle=300
#
##############
#	Receiver
##############
rec_ip=52.77.106.123
rec_port=8082
rec_encrypt=0
#
##############
#	Plugin
##############
type=filetail
hostid=apgapi
ft_dir=/var/log
ft_filter=messages
ft_delim=[newline]
ft_delim_end_of_event=1
ft_start_top=0


type=filetail
hostid=apgapi
ft_dir=/var/log
ft_filter=secure
ft_delim=<newline>
ft_start_top=1' > /opt/McAfee/siem/mcafee_siem_collector.conf 
