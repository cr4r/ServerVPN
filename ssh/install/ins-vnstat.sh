#!/bin/bash

cd $home
# setting vnstat
cmd "/etc/init.d/vnstat restart"
msg -org "Sedang mengupdate vnstat"
wget https://humdi.net/vnstat/vnstat-2.6.tar.gz &>/dev/null
tar zxvf vnstat-2.6.tar.gz &>/dev/null

msg -warn "Sedang build vnstat, mungkin membutuhkan waktu lama"
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc &>/dev/null
make &>/dev/null
make install &>/dev/null
cd $home
msg -org "Konfigurasi vnstat"
vnstat -u -i $NET &>/dev/null
sed -i 's/Interface "'""eth0""'"/Interface "'""$NET""'"/g' /etc/vnstat.conf &>/dev/null
chown vnstat:vnstat /var/lib/vnstat -R &>/dev/null
msg -org "Start VNSTAT"
systemctl enable vnstat &>/dev/null
/etc/init.d/vnstat restart &>/dev/null
rm -rf $home/vnstat-2.6 $home/vnstat-2.6.tar.gz &>/dev/null
