#!/bin/bash


# echo "File Name: $0"
# echo "First Parameter : $1"
# echo "Second Parameter : $2"
# echo "Quoted Values: $@"
# echo "Quoted Values: $*"
# echo "Total Number of Parameters : $#"


ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"


# LAST_EXECUTION_STATUS = $1
# CURRENT_DATE = date +"%Y-%m-%d_%H:%M:%S"
# LOGFILE = /tmp/$CURRENT_FILE_NAME-$CURRENT_DATE.log #filename timestamp logfile


echo "started execution at $CURRENT_DATE" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
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

# vim /etc/yum.repos.d/mongo.repo
cp monorepo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copied mongo repo"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "install mongo repo"


systemctl enable mongod &>> $LOGFILE
VALIDATE $? "enable mongo "

systemctl start mongod &>> $LOGFILE
VALIDATE $? "start mongo"
systemctl status mongod &>> $LOGFILE
VALIDATE $? "status mongo"
#replace 127.0.0.1 with 0.0.0.0 in /etc/mongod.conf
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf  &>> $LOGFILE

VALIDATE $? "Remote access to MongoDB"

systemctl restart mongod &>> $LOGFILE

VALIDATE $? "Restarting MongoDB"