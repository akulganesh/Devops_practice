#!/bin/bash
#This script helps us to configure the redis and configure other properties
#Setup NodeJS repos. Vendor is providing a script to setup the repos.
# Install  redhat-lsb-core package
sudo yum install redhat-lsb-core -y
# Get the operating system version
os_version=$(lsb_release -d)
# Check if the OS version contains a specific pattern
if [[ $os_version == *"8"* ]]; then
  # Run the command for Centos 8
  echo "Running command for Centos 8"
#Redis is offering the repo file as a rpm. Lets install it
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
#Enable Redis 6.2 from package streams.
yum module enable redis:remi-6.2 -y
#Install Redis
yum install redis -y
# changing bind address to 127.0.0.1 to 0.0.0.0
file="/etc/redis.conf"
file1="/etc/redis/redis.conf"
search="127.0.0.1"
replace="0.0.0.0"
sed -i "s/$search/$replace/g" "$file"
sed -i "s/$search/$replace/g" "$file1"
#Start & Enable Redis Service
systemctl enable redis
systemctl start redis
else
  # OS version not supported
  echo "Unsupported operating system version: $os_version"
fi