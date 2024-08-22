# Systemd Service Configuration

## File Location
Service files are stored in `/etc/systemd/system/<SERVICE_NAME>.service`

## Template

```ini
[Unit]
Description=<SERVICE_DESCRIPTION>
Documentation=<DOCUMENTATION_URLS>
Requires=<UNIT>
Wants=<UNIT>
Before=<UNIT>
After=<UNIT>
Conflicts=<UNIT>
BindsTo=<UNIT>

[Service]
Type=<TYPE>
ExecStart=<COMMAND>
ExecStop=<COMMAND>
ExecReload=<COMMAND>
Restart=<OPTION>
RestartSec=<SECONDS>
User=<USERNAME>
Group=<GROUPNAME>
WorkingDirectory=<DIRECTORY>
Environment=<VAR1=VALUE1> <VAR2=VALUE2>
EnvironmentFile=<FILE>
Nice=<NICE_LEVEL>
TimeoutStartSec=<SECONDS>
TimeoutStopSec=<SECONDS>
LimitNOFILE=<VALUE>
KillMode=<MODE>

[Install]
WantedBy=<TARGET>
RequiredBy=<TARGET>
Also=<UNIT>
Alias=<NAME>
DefaultInstance=<INSTANCE>
```

## [Unit] Section Options

| Option | Syntax | Purpose | Example |
|--------|--------|---------|---------|
| Description | `Description=<SERVICE_DESCRIPTION>` | Provides a human-readable description of the unit | `Description=My Custom Web Server` |
| Documentation | `Documentation=<DOCUMENTATION_URLS>` | Provides URLs for documentation | `Documentation=man:myapp(1) https://example.com/docs` |
| Requires | `Requires=<UNIT>` | Configures requirement dependencies on other units | `Requires=network.target` |
| Wants | `Wants=<UNIT>` | Configures weaker dependencies on other units | `Wants=network-online.target` |
| Before | `Before=<UNIT>` | Configures ordering dependencies | `Before=httpd.service` |
| After | `After=<UNIT>` | Configures ordering dependencies | `After=network.target postgresql.service` |
| Conflicts | `Conflicts=<UNIT>` | Configures negative dependencies | `Conflicts=apache2.service nginx.service` |
| BindsTo | `BindsTo=<UNIT>` | Creates a strong dependency on other units | `BindsTo=containerd.service` |

## [Service] Section Options

| Option | Syntax | Purpose | Example |
|--------|--------|---------|---------|
| Type | `Type=<TYPE>` | Configures the process start-up type for this service unit | `Type=simple` |
| ExecStart | `ExecStart=<COMMAND>` | Specifies the command to start the service | `ExecStart=/usr/bin/myapp --config /etc/myapp.conf` |
| ExecStop | `ExecStop=<COMMAND>` | Specifies the command to stop the service | `ExecStop=/usr/bin/myapp --shutdown` |
| ExecReload | `ExecReload=<COMMAND>` | Specifies the command to reload the service configuration | `ExecReload=/bin/kill -HUP $MAINPID` |
| Restart | `Restart=<OPTION>` | Configures whether the service shall be restarted when the service process exits | `Restart=on-failure` |
| RestartSec | `RestartSec=<SECONDS>` | Configures the time to sleep before restarting a service | `RestartSec=30` |
| User | `User=<USERNAME>` | Sets the Unix user under which the service will run | `User=www-data` |
| Group | `Group=<GROUPNAME>` | Sets the Unix group under which the service will run | `Group=www-data` |
| WorkingDirectory | `WorkingDirectory=<DIRECTORY>` | Sets the working directory for executed processes | `WorkingDirectory=/var/www/myapp` |
| Environment | `Environment="VAR1=VALUE1" "VAR2=VALUE2"` | Sets environment variables for executed processes | `Environment="NODE_ENV=production" "PORT=8080"` |
| EnvironmentFile | `EnvironmentFile=<FILE>` | Similar to Environment, but reads the environment variables from a file | `EnvironmentFile=/etc/myapp/env` |
| Nice | `Nice=<NICE_LEVEL>` | Sets the scheduling priority of the executed processes | `Nice=10` |
| TimeoutStartSec | `TimeoutStartSec=<SECONDS>` | Configures the time to wait for start-up | `TimeoutStartSec=30` |
| TimeoutStopSec | `TimeoutStopSec=<SECONDS>` | Configures the time to wait for stop | `TimeoutStopSec=30` |
| LimitNOFILE | `LimitNOFILE=<VALUE>` | Sets the maximum number of file descriptors that can be opened by the service | `LimitNOFILE=65535` |
| KillMode | `KillMode=<MODE>` | Specifies how processes of this unit shall be killed | `KillMode=process` |

### Type Options
- `simple`, `forking`, `oneshot`, `dbus`, `notify`, `idle`

### Restart Options
- `no`, `always`, `on-success`, `on-failure`, `on-abnormal`, `on-abort`, `on-watchdog`

### KillMode Options
- `control-group`, `process`, `mixed`, `none`

## [Install] Section Options

| Option | Syntax | Purpose | Example |
|--------|--------|---------|---------|
| WantedBy | `WantedBy=<TARGET>` | Specifies which target unit should want this service if it's enabled | `WantedBy=multi-user.target` |
| RequiredBy | `RequiredBy=<TARGET>` | Similar to WantedBy, but creates a stronger dependency | `RequiredBy=network-online.target` |
| Also | `Also=<UNIT>` | Specifies additional units to install/enable/disable along with this unit | `Also=my-app-web.service my-app-worker.service` |
| Alias | `Alias=<NAME>` | Provides alternative names for this unit | `Alias=myapp.service webapp.service` |
| DefaultInstance | `DefaultInstance=<INSTANCE>` | For template units, specifies the default instance name | `DefaultInstance=main` |