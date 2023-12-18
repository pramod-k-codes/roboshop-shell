#!/bin/bash

CURRENT_FILE_NAME = $0
CURRENT_DATE = date +"%Y-%m-%d_%H:%M:%S"
LOGFILE = /tmp/$CURRENT_FILE_NAME-$CURRENT_DATE #filename timestamp logfile

# vim /etc/yum.repos.d/mongo.repo
cp monorepo /etc/yum.repos.d/mongo.repo >>
