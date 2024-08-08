#!/bin/bash

# Automated ELK stack install and config

# Update and upgrade the system
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl rsyslog

# Install Elasticsearch, Logstash, Kibana, Filebeat
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
sudo apt-get install apt-transport-https
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
sudo apt-get update -y && sudo apt-get install -y elasticsearch kibana logstash 
# curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.14.3-amd64.deb
# sudo dpkg -i filebeat-8.14.3-amd64.deb
# rm -rf filebeat-8.14.3-amd64.deb
FILEBEAT_VERSION=$(curl -s https://www.elastic.co/downloads/beats/filebeat | grep -oP 'filebeat-8\.[0-9]+\.[0-9]+' | head -n 1)
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/${FILEBEAT_VERSION}-amd64.deb
sudo dpkg -i ${FILEBEAT_VERSION}-amd64.deb
rm -rf ${FILEBEAT_VERSION}-amd64.deb

# Elasticsearch configure (disables https and password requirements for easier use)
sudo awk '
/^xpack.security.enabled:/ { print "xpack.security.enabled: false"; next }
/^xpack.security.enrollment.enabled:/ { print "xpack.security.enrollment.enabled: false"; next }
/^xpack.security.http.ssl:/ {
    print;
    print "  enabled: false";
    getline; getline;
    next
}
/^xpack.security.transport.ssl:/ {
    print;
    print "  enabled: false";
    getline; getline; getline; getline;
    next
}
{ print }
' /etc/elasticsearch/elasticsearch.yml > /tmp/elasticsearch.yml.tmp
sudo mv /tmp/elasticsearch.yml.tmp /etc/elasticsearch/elasticsearch.yml
sudo rm -rf /tmp/elasticsearch.yml.tmp

sudo systemctl enable elasticsearch
sudo systemctl restart elasticsearch

## Kibana configure

sudo systemctl enable kibana
sudo systemctl restart kibana

## Logstash configure
sudo tee /etc/logstash/conf.d/logstash.conf > /dev/null <<EOT
input {
  beats {
    port => 5044
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
  }
}
EOT

sudo systemctl enable logstash
sudo systemctl restart logstash

## Filebeat configure
sudo awk '
/^filebeat.inputs:/,/^  paths:/ {
    if ($0 ~ /^  enabled: false/) {
        print "  enabled: true"
    } else {
        print
    }
    next
}
/^output.elasticsearch:/,/^  preset: balanced/ {
    print "# " $0
    next
}
/^#output.logstash:/,/^  #hosts: \["localhost:5044"\]/ {
    if ($0 ~ /^#output.logstash:/) {
        print "output.logstash:"
    } else if ($0 ~ /^  #hosts: \["localhost:5044"\]/) {
        print "  hosts: [\"localhost:5044\"]"
    } else {
        print substr($0, 2)
    }
    next
}
{ print }
' /etc/filebeat/filebeat.yml > /tmp/filebeat.yml.tmp && sudo mv /tmp/filebeat.yml.tmp /etc/filebeat/filebeat.yml
sudo rm -rf /tmp/filebeat.yml.tmp

sudo systemctl enable filebeat
sudo systemctl restart filebeat

echo "ELK stack installation and configuration completed!"