#!/bin/bash

LOGFILE="/var/log/auto-update.log"
ERRFILE="/var/log/auto-update.err"

sudo apt update -y >> $LOGFILE 2>>$ERRFILE

sudo apt upgrade -y >> $LOGFILE 2>>$ERRFILE

sudo apt autoremove -y >> $LOGFILE 2>>$ERRFILE
sudo apt clean >> $LOGFILE 2>>$ERRFILE

echo "$(date): Update complete." >> $LOGFILE
