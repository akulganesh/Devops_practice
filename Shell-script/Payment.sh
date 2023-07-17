#!/bin/bash
#This script helps us to configure the Payment and configure other properties
#Setup NodeJS repos. Vendor is providing a script to setup the repos.
# Install  redhat-lsb-core package
sudo yum install redhat-lsb-core -y
# Get the operating system version
os_version=$(lsb_release -d)

# Check if the OS version contains a specific pattern
if [[ $os_version == *"8"* ]]; then
  # Run the command for Centos 8
  echo "Running command for Centos 8"
#Install Python 3.6
yum install python36 gcc python3-devel -y
#Configure the application.
#Add application User
useradd roboshop
#setup an app directory.
mkdir /app
#Download the application code to created app directory.
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment.zip
unzip /tmp/payment.zip
#download the dependencies
pip3.6 install -r requirements.txt
#Setup SystemD Payment Service
cat > /etc/systemd/system/payment.service <<- "EOF"
[Unit]
Description=Payment Service

[Service]
User=root
WorkingDirectory=/app
Environment=CART_HOST=cart.agnyaata.online
Environment=CART_PORT=8080
Environment=USER_HOST=user.agnyaata.online
Environment=USER_PORT=8080
Environment=AMQP_HOST=rabbitmq.agnyaata.online
Environment=AMQP_USER=roboshop
Environment=AMQP_PASS=roboshop123

ExecStart=/usr/local/bin/uwsgi --ini payment.ini
ExecStop=/bin/kill -9 $MAINPID
SyslogIdentifier=payment

[Install]
WantedBy=multi-user.target

EOF
#Load the service.
systemctl daemon-reload
#Start the service.
systemctl enable payment
systemctl start payment

else
  # OS version not supported
  echo "Unsupported operating system version: $os_version"
fi