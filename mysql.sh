#!/bin/bash

LOGS_FOLDER="/var/log/expence"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
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
        echo -e "$R please rn this script in root previleges $N" | tee -a &LOG_FILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne o ]
    then
        echo -e "$2 is $R failure $N " | tee -a &LOG_FILE
        exit 1
    else
        echo -e "$2 is $G success $N " | tee -a $LOG_FILE
    fi
}

echo "script started excuiting at: $(date)" | tee -a &LOG_FILE

CHECK_ROOT

dnf install mysql-server -y &>>LOG_FILE
VALIDATE $? "install mysql.server"

systemctl enable mysqld &>>LOG_FILE
VALIDATE $? "enable mysql server"

systemctl start mysqld &>>LOG_FILE
VALIDATE $? "start mysql server"

mysql -h mysql.daws81s.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo "MySQL root password is not setup, setting now" &>>$LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting UP root password"
else
    echo -e "MySQL root password is already setup...$Y SKIPPING $N" | tee -a $LOG_FILE
fi
