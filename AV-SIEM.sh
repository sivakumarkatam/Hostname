sudo su -
echo "starting antivirus install"
yum install -y wget unzip rpm
echo '54.179.180.143  EC2AMAZ-120UKQI' >> /etc/hosts
wget https://s3-ap-southeast-1.amazonaws.com/mcafee-collector/AV/McAfeeSmartInstall.sh
sh McAfeeSmartInstall.sh

echo "installing McAfee agent"
wget https://s3-ap-southeast-1.amazonaws.com/mcafee-collector/SIEM/McAfee_SIEM_Collector_Linux.zip
unzip McAfee_SIEM_Collector_Linux.zip

cd Linux
echo "installing SIEM running rpm file"
rpm -i mcafee-siem-collector-11.00.4150-1575.i686.rpm
echo "rpm install mcAfee"
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
rec_encrypt=1
#
##############
#	Plugin
##############
type=filetail
hostid=
ft_dir=/var/log
ft_filter=messages
ft_delim=[newline]
ft_delim_end_of_event=1
ft_start_top=0
#
type=filetail
hostid=messages
ft_dir=/var/log
ft_filter=auth.log
ft_delim=<newline>
ft_start_top=1
#
type=filetail
hostid=messages
ft_dir=/var/log
ft_filter=secure
ft_delim=<newline>
ft_start_top=1' > /opt/McAfee/siem/mcafee_siem_collector.conf
echo "showing /opt/McAfee/siem/mcafee_siem_collector.conf file"
#cat /opt/McAfee/siem/mcafee_siem_collector.conf
echo "starting siem agent"
/etc/init.d/mcafee_siem_collector start
echo "success"
sleep 2s
cat /var/log/mcafee/siem_collector.log
