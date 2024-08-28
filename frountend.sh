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

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Install nginx"

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enable nginx"

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Start nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "removing the default data"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "doenload the frountend appliction code"

cd /usr/share/nginx/html &>>$LOG_FILE
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzip the code"

cp /home/ec2-user/expence.shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE
VALIDATE $? "copy the code "

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restart the nginx"
