#!/bin.bash

LOGS_FOLDER="/var/lag/expence"
SCRIPT_NAME=$(echo -$0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H=%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER


USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R please run this script in root previleges $N" | tee -a $LOG_FILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
       echo -e "$2 is  $R failure $N " | tee -a $LOG_FILE
       exit 1
    else
        echo -e "$2 is $G success $N " | tee -a $LOG_FILE
    fi 
}

echo "script started  excuiting at: $(date)" | tee -a $LOG_FILE

CHECK_ROOT

dnf install nginx -y 
VALIDATE $? "Install nginx"

systemctl enable nginx
VALIDATE $? "Enable nginx"

systemctl start nginx
VALIDATE $? "Start nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "removing the default data"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip
VALIDATE $? "doenload the frountend appliction code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip
VALIDATE $? "unzip the code"

