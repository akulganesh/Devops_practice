#!/bin/bash
#This script helps us to configure the RabbitMQ and configure other properties
#Setup NodeJS repos. Vendor is providing a script to setup the repos.
# Install  redhat-lsb-core package
sudo yum install redhat-lsb-core -y
# Get the operating system version
os_version=$(lsb_release -d)

# Check if the OS version contains a specific pattern
if [[ $os_version == *"8"* ]]; then
  # Run the command for Centos 8
  echo "Running command for Centos 8"
#Configure YUM Repos from the script provided by vendor.
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash
#Configure YUM Repos for RabbitMQ.
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash
#Install RabbitMQ
yum install rabbitmq-server -y
#Start RabbitMQ Service
systemctl enable rabbitmq-server
systemctl start rabbitmq-server
#RabbitMQ comes with a default username / password as guest/guest. But this user cannot be used to connect.
#Hence, we need to create one user for the application.
rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
else
  # OS version not supported
  echo "Unsupported operating system version: $os_version"
fi