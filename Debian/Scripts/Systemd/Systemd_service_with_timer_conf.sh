#!/bin/bash

SERVICE_NAME=your-service
PATH_TO_SCRIPT=/path/to/your/script.sh

sudo tee -a /etc/systemd/system/${SERVICE_NAME}.service > /dev/null <<EOT
[Unit]
Description=Your Service Description

[Service]
ExecStart=${PATH_TO_SCRIPT}
Type=simple

[Install]
WantedBy=multi-user.target
EOT

sudo tee -a /etc/systemd/system/${SERVICE_NAME}.timer > /dev/null <<EOT
[Unit]
Description=Run Your Hourly Service Every Hour

[Timer]
OnBootSec=1m
OnUnitActiveSec=1h

[Install]
WantedBy=timers.target
EOT

sudo systemctl enable ${SERVICE_NAME}.timer
sudo systemctl start ${SERVICE_NAME}.timer