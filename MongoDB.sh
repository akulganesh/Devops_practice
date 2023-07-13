#!/bin/bash
#This script helps us to configure the mongodb and configure other propertiesz
# setup the monodb repo file
cat > /etc/yum.repos.d/mongo.repo <<- "EOF"
        [mongodb-org-4.2]
        name=MongoDB Repository
        baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
        gpgcheck=0
        enabled=1
EOF
# Installing the MonoDB
yum install mongodb-org -y
# Start & Enable MongoDB Service
systemctl enable mongod
systemctl start mongod
# File path
file="/etc/mongod.conf"

# String to search for
search="127.0.0.1"

# String to replace with
replace="0.0.0.0"

# changing bind address to 127.0.0.1 to 0.0.0.0
sed -i "s/$search/$replace/g" "$file"