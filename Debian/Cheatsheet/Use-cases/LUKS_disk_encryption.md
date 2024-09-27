sudo apt update
sudo apt install cryptsetup

# For partition
sudo cryptsetup luksFormat /dev/sdb1
# For disk
sudo cryptsetup luksFormat /dev/sdb


sudo cryptsetup luksOpen /dev/sdb1 encrypted_volume

sudo mkfs.ext4 /dev/mapper/encrypted_volume

sudo mkdir /mnt/encrypted
sudo mount /dev/mapper/encrypted_volume /mnt/encrypted

# Auto mounting
sudo blkid /dev/sdb1

sudo vim /etc/crypttab

encrypted_volume UUID=<uuid_from_blkid> none luks

sudo vim /etc/fstab

/dev/mapper/encrypted_volume /mnt/encrypted ext4 defaults 0 2