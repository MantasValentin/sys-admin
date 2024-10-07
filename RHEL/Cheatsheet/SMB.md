# Server

sudo dnf install samba -y

sudo systemctl enable --now smb
sudo systemctl enable --now nmb

sudo systemctl enable --now firewalld
sudo firewall-cmd --permanent --add-service samba
sudo firewall-cmd --reload

sudo groupadd sambashare
sudo adduser -M sambauser -s /sbin/nologin
sudo smbpasswd -a sambauser
# Enter password when prompted
sudo usermod -aG sambashare sambauser

sudo mkdir /sambashare
sudo chown -R nobody:sambashare /sambashare
sudo chmod -R 0770 /sambashare
sudo chcon -R -t samba_share_t /sambashare/

/etc/samba/smb.conf
[sambashare]
   path = /sambashare
   browseable = yes
   writeable = yes
   read only = no
   force create mode = 0770
   force directory mode = 2770
   force group = sambashare
   valid users = @sambashare

sudo systemctl restart {smb,nmb}

# test

testparm /etc/samba/smb.conf

# Client

sudo dnf install samba-client cifs-utils -y

sudo mkdir /mnt/sambashare
sudo groupadd -g 1100 sambashare
# Add user to group
sudo usermod -aG sambashare <user>

sudo vim /etc/samba/credentials
username=sambauser
password=<samba_password>

sudo chmod 600 /etc/samba/credentials

# to make perminant add to /etc/fstab

//<server_ip>/sambashare /mnt/sambashare cifs credentials=/etc/samba/credentials,gid=1100,file_mode=0775,dir_mode=0775 0 0

systemctl daemon-reload

sudo umount /mnt/sambashare
sudo mount -a

# Need for the group change to take effect so either log out and log in or reboot and check if it auto mounts
reboot