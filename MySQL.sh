#!/bin/bash
#This script helps us to configure the MySql and configure other properties
#Setup NodeJS repos. Vendor is providing a script to setup the repos.
# Install  redhat-lsb-core package
sudo yum install redhat-lsb-core -y
# Get the operating system version
os_version=$(lsb_release -d)
# Check if the OS version contains a specific pattern
if [[ $os_version == *"8"* ]]; then
  # Run the command for Centos 8
  echo "Running command for Centos 8"
#CentOS-8 Comes with MySQL 8 Version by default, However our application needs MySQL 5.7. So lets disable MySQL 8 version.
yum module disable mysql -y
#Setup the MySQL5.7 repo file
cat > /etc/yum.repos.d/mysql.repo <<- "EOF"
[mysql]
name=MySQL 5.7 Community Server
baseurl=http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/
enabled=1
gpgcheck=0
EOF
#Install MySQL Server
yum install mysql-community-server -y
#Start MySQL Service
systemctl enable mysqld
systemctl start mysqld
#default root password in order to start using the database service. Use password RoboShop@1
mysql_secure_installation --set-root-pass RoboShop@1
#check the new password working or not using the following command in MySQL.
mysql -uroot -pRoboShop@1
## above command need to be verify over the shell script
else
  # OS version not supported
  echo "Unsupported operating system version: $os_version"
fi