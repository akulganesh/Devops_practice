#!/bin/bash
#This script helps us to configure the Catalogue and configure other properties
#Setup NodeJS repos. Vendor is providing a script to setup the repos.
# Install  redhat-lsb-core package
sudo yum install redhat-lsb-core -y
# Get the operating system version
os_version=$(lsb_release -d)

# Check if the OS version contains a specific pattern
if [[ $os_version == *"8"* ]]; then
  # Run the command for Centos 8
  echo "Running command for Centos 8"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash
#Install NodeJS
yum install nodejs -y
#Add application User
useradd roboshop
#creating application directory
mkdir /app
#Download the application code to created app directory.
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip
unzip /tmp/catalogue.zip
#Lets download the dependencies.
npm install
#creating catalogue.service
cat > /etc/systemd/system/catalogue.service <<- "EOF"
[Unit]
Description = Catalogue Service

[Service]
User=roboshop
Environment=MONGO=true
Environment=MONGO_URL="mongodb://monogodb.agnyaata.online:27017/catalogue"
ExecStart=/bin/node /app/server.js
SyslogIdentifier=catalogue

[Install]
WantedBy=multi-user.target
EOF
#Load the service.
systemctl daemon-reload
#Start the service.
systemctl enable catalogue
systemctl start catalogue
#setup MongoDB repo and install mongodb-client
cat > /etc/yum.repos.d/mongo.repo <<- "EOF"
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=0
enabled=1
EOF
yum update
yum install mongodb-org-shell -y
#Load Schema
mongo --host monogodb.agnyaata.online </app/schema/catalogue.js
else
  # OS version not supported
  echo "Unsupported operating system version: $os_version"
fi
