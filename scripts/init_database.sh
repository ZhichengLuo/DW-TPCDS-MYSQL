#!/bin/bash
# autor: ZhichengLuo
# email: zcsysu@163.com

if [ $#  -lt 1 ]; then
    echo "USAGE: ./init_database.sh <DATABASE>"
    echo "ERROR: parameter missing"
    exit 1
fi

DATABASE=$1

mysql -e "drop database $DATABASE"

mysql -e "create database $DATABASE"

mysql -D$DATABASE < ../DSGen-software-code-3.2.0rc1/tools/tpcds.sql