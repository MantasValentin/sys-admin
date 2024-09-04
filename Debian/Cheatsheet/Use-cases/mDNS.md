sudo apt-get install avahi-daemon avahi-utils -y

sudo vim /etc/avahi/avahi-daemon.conf

[server]
use-ipv4=yes
use-ipv6=yes
allow-interfaces=eth0,wlan0

[reflector]
enable-reflector=yes

sudo systemctl enable avahi-daemon
sudo systemctl restart avahi-daemon




sudo vim /etc/avahi/services/test.service

<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">Test Service</name>
  <service>
    <type>_test._tcp</type>
    <port>12345</port>
  </service>
</service-group>


avahi-browse -a
avahi-browse -r service_name