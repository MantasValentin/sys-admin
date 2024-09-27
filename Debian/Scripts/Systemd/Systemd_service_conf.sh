#!/bin/bash

SERVICE_NAME=your-service

sudo tee -a /etc/systemd/system/${SERVICE_NAME}.service > /dev/null <<EOT
[Unit]
Description="Your Service Description"

[Service]
ExecStart=/path/to/your/script.sh
Type=simple

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl enable ${SERVICE_NAME}.service
sudo systemctl start ${SERVICE_NAME}.service