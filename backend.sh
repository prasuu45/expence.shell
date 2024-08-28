#!/bin.bash

LOGS_FOLDER="/var/lag/expence"
SCRIPT_NAME=$(echo -$0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H=%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER


USERID=$(id -u)
R="/e[31m"
G="/e[32m"
Y="/e[33m"
N="/e[0m"

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

dnf module disable nodejs -y &>>LOG_FILE
VALIDATE $? "Disable nodejs module"

dnf module enable nodejs:20 -y &>>LOG_FILE
VALIDATE $? "Enable nodejs:20"

dnf install nodejs -y &>>LOG_FILE
VALIDATE $? "Install nodejs"

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo -e "expense user not exists... $G Creating $N"
    useradd expense &>>$LOG_FILE
    VALIDATE $? "Creating expense user"
else
    echo -e "expense user already exists...$Y SKIPPING $N"
fi


mkdir -p /app &>>LOG_FILE
VALIDATE $? "Create /app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOG_FILE
VALIDATE $? "download the application code"

cd /app  &>>LOG_FILE
rm -rf /app * # remove the exiting code
unzip /tmp/backend.zip
VALIDATE $? "Extrating the code"

npm install &>>LOG_FILE
VALIDATE $? "install npm"

dnf install mysql -y &>>LOG_FILE
VALIDATE $? "install mysql clinet"

mysql -h 172.31.32.52 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>LOG_FILE
VALIDATE $? " schema loading"

systemctl daemon-reload &>>LOG_FILE
VALIDATE $? "Reaload the daemon"

systemctl enable backend &>>LOG_FILE
VALIDATE $? "enable backend server"

systemctl restart backend &>>LOG_FILE
VALIDATE $? "start the backend server"

