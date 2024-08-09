# Full disk backup
sudo dd if=/dev/sdX of=/path/to/disk_image.img bs=4M status=progress

# Restoring a disk image
dd if=/path/to/disk_image.img of=/dev/sdX bs=4M status=progress

# Local file synchronization
rsync -avh --progress /source/directory/ /destination/directory/

# Remote file synchronization
rsync -avzh --progress -e ssh /local/directory/ user@remote:/remote/directory/

# Backing up data
rsync -avbh --backup-dir=/path/to/backups/$(date +%Y-%m-%d) /source/ /destination/