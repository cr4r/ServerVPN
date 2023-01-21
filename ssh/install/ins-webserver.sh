#!/bin/bash

msg -line " Menginstall Web Server "
msg -org "Menghapus default pada nginx"
rm /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default &>/dev/null

# msg -org "Membuat konfigurasi pada /etc/nginx/nginx.conf"
# curl ${pssh}/nginx.conf >/etc/nginx/nginx.conf &>/dev/null

msg -org "Membuat konfigurasi pada /etc/nginx/conf.d/vps.conf"
cat <<EOF >/etc/nginx/conf.d/vps.conf
server {
  listen       ${webserver_nginx};
  server_name  127.0.0.1 localhost;
  access_log /var/log/nginx/vps-access.log;
  error_log /var/log/nginx/vps-error.log error;
  root   /home/vps/public_html;

  location / {
    index  index.html index.htm index.php;
    try_files \$uri \$uri/ /index.php?\$args;
  }

  location ~ \\.php\$ {
    include /etc/nginx/fastcgi_params;
    fastcgi_pass  127.0.0.1:${webserver_php};
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
  }
}
EOF
# curl ${pssh}/vps.conf >/etc/nginx/conf.d/vps.conf &>/dev/null

msg -org "sed -i 's/listen = \/var\/run\/php-fpm.sock/listen = 127.0.0.1:$webserver_php/g' /etc/php/fpm/pool.d/www.conf"
sed -i "s/listen = \/var\/run\/php-fpm.sock/listen = 127.0.0.1:$webserver_php/g" /etc/php/fpm/pool.d/www.conf

msg -red "Membuat user *vps*"
useradd -m vps &>/dev/null

msg -org "Membuat folder /home/vps/public_html"
mkdir -p /home/vps/public_html

msg -org "echo \"<?php phpinfo() ?>\" >/home/vps/public_html/info.php"
echo "<?php phpinfo() ?>" >/home/vps/public_html/info.php &>/dev/null

msg -org "chown -R www-data:www-data /home/vps/public_html"
chown -R www-data:www-data /home/vps/public_html &>/dev/null

msg -org "chmod -R g+rw /home/vps/public_html"
chmod -R g+rw /home/vps/public_html &>/dev/null

msg -org "Menuju ke /home/vps/public_html"
cd /home/vps/public_html

msg -org "wget -O /home/vps/public_html/index.html "${pssh}/index.html1""
wget -O /home/vps/public_html/index.html "${pssh}/index.html1" &>/dev/null

msg -warn "Restart Nginx"
cmd "/etc/init.d/nginx restart"

cd $home
c_port $file_port webserver_php $webserver_php
c_port $file_port webserver_php $webserver_nginx

ufw allow $webserver_nginx/udp &>/dev/null
ufw allow $webserver_nginx/tcp &>/dev/null
