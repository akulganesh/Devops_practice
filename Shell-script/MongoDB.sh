#!/bin/bash
#This script helps us to configure the mongodb and configure other propertiesz
# setup the monodb repo file
# Install  redhat-lsb-core package
sudo yum install redhat-lsb-core -y
# Get the operating system version
os_version=$(lsb_release -d)
# Check if the OS version contains a specific pattern
if [[ $os_version == *"8"* ]]; then
  # Run the command for Centos 8
  echo "Running command for Centos 8"
cat > /etc/yum.repos.d/mongo.repo <<- "EOF"
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=0
enabled=1
EOF
yum update
# Installing the MonoDB
yum install mongodb-org -y
# Start & Enable MongoDB Service
systemctl enable mongod
systemctl start mongod
# changing bind address to 127.0.0.1 to 0.0.0.0
file="/etc/mongod.conf"
search="127.0.0.1"
replace="0.0.0.0"
sed -i "s/$search/$replace/g" "$file"
else
  # OS version not supported
  echo "Unsupported operating system version: $os_version"
fi