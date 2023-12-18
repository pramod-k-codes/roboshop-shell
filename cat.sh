#!/bin/bash


ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
MONGDB_HOST=mgdb.pktes.shop


# LAST_EXECUTION_STATUS = $1
# CURRENT_DATE = date +"%Y-%m-%d_%H:%M:%S"
# LOGFILE = /tmp/$CURRENT_FILE_NAME-$CURRENT_DATE.log #filename timestamp logfile


echo "started execution at $CURRENT_DATE" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        echo "log path $LOGFILE" &>> $LOGFILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}
#check root access
if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end


dnf module disable nodejs -y  &>> $LOGFILE
dnf module enable nodejs:18 -y  &>> $LOGFILE

dnf install nodejs -y &>> $LOGFILE

id roboshop  &>> $LOGFILE
if [ $? -eq 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "directory creation"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip  &>> $LOGFILE
VALIDATE $? "downloading catalogue"

cd /app &>> $LOGFILE
VALIDATE $? "cd to app"

unzip /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "unzip catalogue"

cd /app &>> $LOGFILE
VALIDATE $? "cd to app"

npm install &>> $LOGFILE
VALIDATE $? "npm install"


# use absolute, because catalogue.service exists there
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

systemctl daemon-reload
VALIDATE $? "systemctl daemon-reload"

systemctl enable catalogue
VALIDATE $? "systemctl enable catalogue"

systemctl start catalogue
VALIDATE $? "systemctl start catalogue"

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copying mongo repo"
dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "mongodb-org-shell installation"
mongo --host $MONGDB_HOST </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "Loading catalouge data into MongoDB"