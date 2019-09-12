#!/bin/sh

# Конфигурация Frontend
echo "<?php" > /var/www/html/conf/zabbix.conf.php
echo "// Zabbix GUI configuration file." >> /var/www/html/conf/zabbix.conf.php
echo "global \$DB;" >> /var/www/html/conf/zabbix.conf.php
echo "" >> /var/www/html/conf/zabbix.conf.php
echo "\$DB['TYPE']     = 'MYSQL';" >> /var/www/html/conf/zabbix.conf.php
echo "\$DB['SERVER']   = '$ZABBIX_DB_HOST';" >> /var/www/html/conf/zabbix.conf.php
echo "\$DB['PORT']     = '0';" >> /var/www/html/conf/zabbix.conf.php
echo "\$DB['DATABASE'] = '$ZABBIX_DB_NAME';" >> /var/www/html/conf/zabbix.conf.php
echo "\$DB['USER']     = '$ZABBIX_DB_USER';" >> /var/www/html/conf/zabbix.conf.php
echo "\$DB['PASSWORD'] = '$ZABBIX_DB_PASSWORD';" >> /var/www/html/conf/zabbix.conf.php
echo "" >> /var/www/html/conf/zabbix.conf.php
echo "// Schema name. Used for IBM DB2 and PostgreSQL." >> /var/www/html/conf/zabbix.conf.php
echo "\$DB['SCHEMA'] = '';" >> /var/www/html/conf/zabbix.conf.php
echo "" >> /var/www/html/conf/zabbix.conf.php
echo "\$ZBX_SERVER      = 'localhost';" >> /var/www/html/conf/zabbix.conf.php
echo "\$ZBX_SERVER_PORT = '10051';" >> /var/www/html/conf/zabbix.conf.php
echo "\$ZBX_SERVER_NAME = '';" >> /var/www/html/conf/zabbix.conf.php
echo "" >> /var/www/html/conf/zabbix.conf.php
echo "\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;" >> /var/www/html/conf/zabbix.conf.php

# Конфигурация сервера и агента
echo "LogFile=/tmp/zabbix_agentd.log" > /usr/local/etc/zabbix_agentd.conf
echo "Server=127.0.0.1"  >> /usr/local/etc/zabbix_agentd.conf
echo "LogType=console" >> /usr/local/etc/zabbix_agentd.conf
echo "ServerActive=127.0.0.1"  >> /usr/local/etc/zabbix_agentd.conf
echo "Hostname=zabbix-server"  >> /usr/local/etc/zabbix_agentd.conf

echo "ListenPort=10051 " > /usr/local/etc/zabbix_server.conf
echo "LogType=console " >> /usr/local/etc/zabbix_server.conf
echo "LogFile=/tmp/zabbix_server.log" >> /usr/local/etc/zabbix_server.conf
echo "DBHost=$ZABBIX_DB_HOST" >> /usr/local/etc/zabbix_server.conf
echo "DBName=$ZABBIX_DB_NAME" >> /usr/local/etc/zabbix_server.conf
echo "DBUser=$ZABBIX_DB_USER" >> /usr/local/etc/zabbix_server.conf
echo "DBPassword=$ZABBIX_DB_PASSWORD" >> /usr/local/etc/zabbix_server.conf
echo "ListenIP=0.0.0.0" >> /usr/local/etc/zabbix_server.conf
echo "Timeout=30" >> /usr/local/etc/zabbix_server.conf
echo "LogSlowQueries=3000" >> /usr/local/etc/zabbix_server.conf
echo "StatsAllowedIP=127.0.0.1" >> /usr/local/etc/zabbix_server.conf


su zabbix -c "/usr/local/sbin/zabbix_agentd -f" &
su zabbix -c "/usr/local/sbin/zabbix_server -f" &
/usr/sbin/nginx -g 'daemon off;' &
/usr/sbin/php-fpm7.3 -F


exit 0