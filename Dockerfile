FROM ubuntu:xenial

# Подключаем репозитарий и устанавливаем пакеты PHP-7.3
RUN apt-get update && apt-get -y install curl apt-transport-https ca-certificates && \
    apt-get -y install gnupg-agent software-properties-common && \
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php && apt-get update &&\
    apt-get -y install php7.3 php7.3-cli php7.3-common php7.3-fpm php7.3-ldap && \
    apt-get -y install php7.3 php7.3-mbstring php7.3-xmlrpc php7.3-soap php7.3-bcmath && \
    apt-get -y install php7.3-gd php7.3-xml php7.3-intl php7.3-mysql php7.3-zip php7.3-curl php7.3-fpm

# Устанавливаем Nginx
RUN apt-get install -y nginx-full

# Пакеты для диагностики (в прод отключаем)
RUN apt-get install -y inetutils-ping dnsutils net-tools mc

# Конфигурация для WEB-приложения
RUN rm /var/www/html/index.nginx-debian.html
COPY ./nginx-app-config.conf /etc/nginx/sites-enabled/default

# Копируем исходные коды Zabbix
COPY ./zabbix/ /usr/src/zabbix/
# Копируем Frontend
RUN cp -R /usr/src/zabbix/frontends/php/* /var/www/html/
RUN chown -R www-data:www-data /var/www/html/

# Сборка Zabbix-сервера и Zabbix-агента из исходных кодов
RUN apt-get install -y build-essential automake autoconf fping &&\
    apt-get install -y pkg-config libpcre2-dev libpcre++-dev libsnmp-dev libssh-dev libssh2-1-dev libopenipmi-dev &&\
    apt-get install -y libevent-dev libldap2-dev libcurl4-openssl-dev libxml2-dev libmysqlclient-dev mysql-client &&\
    ln -s /usr/bin/fping /usr/sbin/fping

RUN cd /usr/src/zabbix/ &&\
    ./bootstrap.sh &&\
    ./configure --enable-server --enable-agent --with-mysql --with-libxml2 --with-net-snmp --with-ssh2 \
   --with-openipmi --with-libevent --with-libpcre --with-openssl --with-ldap --with-libcurl &&\
   make dbschema && make && make install

# Определяем переменные для подключения к базе данных Zabbix
ENV ZABBIX_DB_USER "db-user"
ENV ZABBIX_DB_PASSWORD "db-password"
ENV ZABBIX_DB_NAME "db-name"
ENV ZABBIX_DB_HOST "db-host"

# Перенаправляем вывод логов в stdout и stderr
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# Создаем пользователя и группу zabbix
RUN groupadd zabbix &&\
    useradd -g zabbix zabbix &&\
    mkdir /var/log/zabbix/ &&\
    chown zabbix:zabbix /var/log/zabbix/ &&\
    mkdir /var/run/zabbix/ &&\
    chown zabbix:zabbix /var/run/zabbix/

RUN mkdir /run/php/

# Создаем конфигурационные файлы и скрипт запуска согласно переменных окружения
COPY ./run.sh /opt/
RUN chmod +x /opt/run.sh

EXPOSE 8080
STOPSIGNAL SIGTERM

CMD /opt/run.sh
