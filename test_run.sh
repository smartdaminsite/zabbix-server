#!/bin/sh

docker build -t smartdminsite/zabbix:latest .
docker run -p 127.0.0.1:9090:8080 -it --name zabbix-test smartdminsite/zabbix:latest bash
docker rm zabbix-test