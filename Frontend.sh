#!/bin/bash
#  we are using centos operating system to verify os version we are installing another package based on condition it will execute next commands
# to get os version
# Install  redhat-lsb-core package
sudo yum install redhat-lsb-core -y
# Get the operating system version
os_version=$(lsb_release -d)

# Check if the OS version contains a specific pattern
if [[ $os_version == *"8"* ]]; then
  # Run the command for Centos 8
  echo "Running command for Centos 8"
  yum update -y
  yum install nginx -y
  systemctl enable nginx
  systemctl start nginx
  rm -rf /usr/share/nginx/html/*
  curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip
  unzip /tmp/frontend.zip
# creating file roboshop.conf file and inject file context inline command using cat
cat > /etc/nginx/default.d/roboshop.conf <<- "EOF"
proxy_http_version 1.1;
location /images/ {
expires 5s;
root   /usr/share/nginx/html;
try_files $uri /images/placeholder.jpg;
}
location /api/catalogue/ { proxy_pass http://catalogue.agnyaata.online:8080/; }
location /api/user/ { proxy_pass http://user.agnyaata.online:8080/; }
location /api/cart/ { proxy_pass http://cart.agnyaata.online:8080/; }
location /api/shipping/ { proxy_pass http://shipping.agnyaata.online:8080/; }
location /api/payment/ { proxy_pass http://payment.agnyaata.online:8080/; }
location /health {
stub_status on;
access_log off;
}
EOF
#nginx service status check
systemctl status nginx
else
  # OS version not supported
  echo "Unsupported operating system version: $os_version"
fi