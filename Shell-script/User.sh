#!/bin/bash
#This script helps us to configure the User and configure other properties
#Setup NodeJS repos. Vendor is providing a script to setup the repos.
# Install  redhat-lsb-core package
sudo yum install redhat-lsb-core -y
# Get the operating system version
os_version=$(lsb_release -d)

# Check if the OS version contains a specific pattern
if [[ $os_version == *"8"* ]]; then
  # Run the command for Centos 8
  echo "Running command for Centos 8"
#Setup NodeJS repos. Vendor is providing a script to setup the repos.
curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install nodejs -y
#Add application User
useradd roboshop
#setup an app directory.
mkdir /app
#Download the application code to created app directory.
curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user.zip
unzip /tmp/user.zip
#download the dependencies.
npm install
#Setup SystemD User Service
cat > /etc/systemd/system/user.service <<- "EOF"

[Unit]
Description = User Service
[Service]
User=roboshop
Environment=MONGO=true
Environment=REDIS_HOST=<REDIS-SERVER-IP>
Environment=MONGO_URL="mongodb://monogodb.agnyaata.online:27017/users"
ExecStart=/bin/node /app/server.js
SyslogIdentifier=user

[Install]
WantedBy=multi-user.target

EOF
#Load the service.
systemctl daemon-reload
#Start the service.
systemctl enable user
systemctl start user
#We need to load the schema. To load schema we need to install mongodb client.
#To have it installed we can setup MongoDB repo and install mongodb-client
cat > /etc/yum.repos.d/mongo.repo <<- "EOF"
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=0
enabled=1

EOF
#Install monogodb client package.
yum install mongodb-org-shell -y
#Load Schema
mongo --host monogodb.agnyaata.online </app/schema/user.js
else
  # OS version not supported
  echo "Unsupported operating system version: $os_version"
fi