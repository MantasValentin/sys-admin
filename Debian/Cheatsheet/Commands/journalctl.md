# Filter logs by systemd unit
journalctl -u ssh

# Grep
journalctl -g USER=root

# Follow logs in real time
journalctl -f

# View logs in from end to start
journalctl -r

# Filter logs by date and time
journalctl --since "2024-08-29 09:00:00" --until "2024-08-29 17:00:00"

# Filter logs by priority
journalctl -p err

# Filter logs by user
journalctl _UID=1000

# Filter logs by process id
journalctl _PID=1234

# Output logs in specify format
journalctl -o json




# Check disk usage
journalctl --disk-usage

# Rotate logs
journalctl --rotate

# Delete oldest logs if more than
journalctl --vacuum-size=500M

# You get the point
journalctl --vacuum-time=1week

# Check journal health
journalctl --verify