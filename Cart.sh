#!/bin/bash
#This script helps us to configure the Cart and configure other properties
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
#Install NodeJS
yum install nodejs -y
#Add application User
useradd roboshop
#setup an app directory.
mkdir /app
#Download the application code to created app directory.
curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart.zip
unzip /tmp/cart.zip
#download the dependencies.
npm install
#Setup SystemD Cart Service
cat > /etc/systemd/system/cart.service <<- "EOF"

[Unit]
Description = Cart Service
[Service]
User=roboshop
Environment=REDIS_HOST=redis.agnyaata.online
Environment=CATALOGUE_HOST=catalogue.agnyaata.online
Environment=CATALOGUE_PORT=8080
ExecStart=/bin/node /app/server.js
SyslogIdentifier=cart

[Install]
WantedBy=multi-user.target

EOF
#Load the service.
systemctl daemon-reload
#Start the service.
systemctl enable cart
systemctl start cart
else
  # OS version not supported
  echo "Unsupported operating system version: $os_version"
fi