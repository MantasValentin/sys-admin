# Server

sudo dnf install nfs-utils -y

sudo systemctl enable --now nfs-server
sudo systemctl enable --now rpcbind

sudo mkdir -p /nfs/exports/myshare

echo "/nfs/exports/myshare 192.168.0.0/24(rw)" > /etc/exports
/nfs/exports/myshare 192.168.0.0/24(rw,sync,no_root_squash,no_all_squash,anonuid=65534,anongid=1001)

sudo chown -R root:staff /nfs/exports/myshare
sudo chmod -R 2775 /nfs/exports/myshare

sudo exportfs -ra

sudo firewall-cmd --add-service nfs --permanent
sudo firewall-cmd --add-port=2049/tcp --add-port=2049/udp --permanent
sudo firewall-cmd --add-port=111/tcp --add-port=111/udp --permanent
sudo firewall-cmd --reload

# Client

sudo dnf install nfs-utils -y

sudo mkdir -p /nfs/imports/myshare

sudo mount -v -t nfs 192.168.0.222:/nfs/exports/myshare /nfs/imports/myshare/
sudo umount /nfs/imports/myshare

sudo chown root:staff /nfs/imports/myshare
sudo chmod 2775 /nfs/imports/myshare

# /etc/fstab
192.168.0.222:/nfs/exports/myshare   /nfs/imports/myshare/  nfs  rw 0 0

# Remount
sudo mount -a

# Check
sudo mount | grep -i nfs


