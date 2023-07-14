#!/bin/bash
#This script helps us to configure the shipping and configure other properties
#Setup NodeJS repos. Vendor is providing a script to setup the repos.
# Install  redhat-lsb-core package
sudo yum install redhat-lsb-core -y
# Get the operating system version
os_version=$(lsb_release -d)

# Check if the OS version contains a specific pattern
if [[ $os_version == *"8"* ]]; then
  # Run the command for Centos 8
  echo "Running command for Centos 8"
#Shipping service is written in Java, Hence we need to install Java.
yum install maven -y
#Add application User
useradd roboshop
# setup an app directory.
mkdir /app
#Download the application code to created app directory.
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping.zip
unzip /tmp/shipping.zip
#download the dependencies & build the application
mvn clean package
mv target/shipping-1.0.jar shipping.jar
#Setup SystemD Shipping Service
cat > /etc/systemd/system/shipping.service <<- "EOF"
[Unit]
Description=Shipping Service

[Service]
User=roboshop
Environment=CART_ENDPOINT=cart.agnyaata.online:8080
Environment=DB_HOST=mysql.agnyaata.online
ExecStart=/bin/java -jar /app/shipping.jar
SyslogIdentifier=shipping

[Install]
WantedBy=multi-user.target
EOF
#Load the service.
systemctl daemon-reload
#Start the service.
systemctl enable shipping
systemctl start shipping
#load the schema. To load schema we need to install mysql client.
yum install mysql -y
#Load Schema
mysql -h mysql.agnyaata.online -uroot -pRoboShop@1 < /app/schema/shipping.sql
#restart the service after loading the schema
systemctl restart shipping
systemctl status shipping
else
  # OS version not supported
  echo "Unsupported operating system version: $os_version"
fi