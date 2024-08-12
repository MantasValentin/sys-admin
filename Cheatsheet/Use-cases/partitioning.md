# Check partitions
sudo df -h
sudo fdisk -l

# Modify partitions
## MBR
sudo fdisk /dev/sdX
## GPT
sudo gdisk /dev/sdX
## Check partition type
sudo parted /dev/sdX print

# Formating
## For linux
sudo mkfs.ext4 /dev/sdXY

## For windows
sudo mkfs.ntfs /dev/sdXY

## Check format
sudo blkid /dev/sdXY

# Mounting
sudo mount /dev/sdXY /mnt/partition

# Unmounting
sudo umount /mnt/partition