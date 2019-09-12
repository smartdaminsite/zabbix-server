#!/bin/sh

docker build -t smartdminsite/zabbix:latest .
docker run -it --name zabbix-test smartdminsite/zabbix:latest bash
docker rm zabbix-test