# Check drivers
lsblk

# Create Raid level 0
mdadm --create --verbose /dev/md0 --level=0 --raid-devices=2 /dev/sda /dev/sdb
mkfs.xfs /dev/md0
mkdir -p /mnt/md0
mount /dev/md0 /mnt/md0
mdadm --detail --scan >> /etc/mdadm.conf
dracut -f
echo '/dev/md0 /mnt/md0 xfs defaults,nofail 0 0' >> /etc/fstab

# Create Raid level 1
mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/sda /dev/sdb
mkfs.xfs /dev/md0
mkdir -p /mnt/md0
mount /dev/md0 /mnt/md0
mdadm --detail --scan >> /etc/mdadm.conf
dracut -f
echo '/dev/md0 /mnt/md0 xfs defaults,nofail 0 0' >> /etc/fstab

# Create Raid level 5
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 /dev/sda /dev/sdb /dev/sdc
# Wait until the array finishes building
cat /proc/mdstat
mkfs.xfs /dev/md0
mkdir -p /mnt/md0
mount /dev/md0 /mnt/md0
mdadm --detail --scan >> /etc/mdadm.conf
dracut -f
echo '/dev/md0 /mnt/md0 xfs defaults,nofail 0 0' >> /etc/fstab

# Create Raid level 6
mdadm --create --verbose /dev/md0 --level=6 --raid-devices=4 /dev/sda /dev/sdb /dev/sdc /dev/sdd
# Wait until the array finishes building
cat /proc/mdstat
mkfs.xfs /dev/md0
mkdir -p /mnt/md0
mount /dev/md0 /mnt/md0
mdadm --detail --scan >> /etc/mdadm.conf
dracut -f
echo '/dev/md0 /mnt/md0 xfs defaults,nofail 0 0' >> /etc/fstab

# Create Raid level 10
mdadm --create --verbose /dev/md0 --level=10 --raid-devices=4 /dev/sda /dev/sdb /dev/sdc /dev/sdd
mkfs.xfs /dev/md0
mkdir -p /mnt/md0
mount /dev/md0 /mnt/md0
mdadm --detail --scan >> /etc/mdadm.conf
dracut -f
echo '/dev/md0 /mnt/md0 xfs defaults,nofail 0 0' >> /etc/fstab

# Check active RAID devices
cat /proc/mdstat
mdadm --detail /dev/md0

# Add additional disk to RAID array
mdadm --manage /dev/md0 --add /dev/sdd
mdadm --grow --size=max /dev/md0