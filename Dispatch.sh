#!/bin/bash
#This script helps us to configure the Dispatch and configure other properties
#Setup NodeJS repos. Vendor is providing a script to setup the repos.
# Install  redhat-lsb-core package
sudo yum install redhat-lsb-core -y
# Get the operating system version
os_version=$(lsb_release -d)
# Check if the OS version contains a specific pattern
if [[ $os_version == *"8"* ]]; then
  # Run the command for Centos 8
  echo "Running command for Centos 8"
#Install GoLang
yum install golang -y
#Add application User
useradd roboshop
#Lets setup an app directory.
mkdir /app
#Download the application code to created app directory.
curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch.zip
unzip /tmp/dispatch.zip
#download the dependencies & build the software.
go mod init dispatch
go get
go build
#Setup SystemD Payment Service
cat > /etc/systemd/system/dispatch.service <<- "EOF"
[Unit]
Description = Dispatch Service
[Service]
User=roboshop
Environment=AMQP_HOST=rabbitmq.agnyaata.online
Environment=AMQP_USER=roboshop
Environment=AMQP_PASS=roboshop123
ExecStart=/app/dispatch
SyslogIdentifier=dispatch

[Install]
WantedBy=multi-user.target
EOF
else
  # OS version not supported
  echo "Unsupported operating system version: $os_version"
fi