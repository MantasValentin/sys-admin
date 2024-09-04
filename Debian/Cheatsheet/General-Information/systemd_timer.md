# Systemd Timer Configuration

## File Location
Timer files are stored in `/etc/systemd/system/<TIMER_NAME>.timer`

## Template

```ini
[Unit]
Description=<TIMER_DESCRIPTION>
Documentation=<DOCUMENTATION_URLS>
Requires=<UNIT>
Wants=<UNIT>
Before=<UNIT>
After=<UNIT>
Conflicts=<UNIT>

[Timer]
OnBootSec=<TIME>
OnStartupSec=<TIME>
OnActiveSec=<TIME>
OnUnitActiveSec=<TIME>
OnUnitInactiveSec=<TIME>
OnCalendar=<CALENDAR_SPEC>
AccuracySec=<TIME>
RandomizedDelaySec=<TIME>
Unit=<SERVICE_UNIT>
Persistent=<BOOLEAN>
WakeSystem=<BOOLEAN>
RemainAfterElapse=<BOOLEAN>
Trigger=<BOOLEAN>

[Install]
WantedBy=<TARGET>
RequiredBy=<TARGET>
Also=<UNIT>
Alias=<NAME>
```

## [Unit] Section Options

| Option | Syntax | Purpose | Example |
|--------|--------|---------|---------|
| Description | `Description=<TIMER_DESCRIPTION>` | Provides a human-readable description of the timer | `Description=Daily System Backup Timer` |
| Documentation | `Documentation=<DOCUMENTATION_URLS>` | Provides URLs for documentation | `Documentation=man:systemd-timer(5) https://example.com/docs` |
| Requires | `Requires=<UNIT>` | Configures requirement dependencies on other units | `Requires=network.target` |
| Wants | `Wants=<UNIT>` | Configures weaker dependencies on other units | `Wants=network-online.target` |
| Before | `Before=<UNIT>` | Configures ordering dependencies | `Before=backup.service` |
| After | `After=<UNIT>` | Configures ordering dependencies | `After=network.target` |
| Conflicts | `Conflicts=<UNIT>` | Configures negative dependencies | `Conflicts=shutdown.target` |

## [Timer] Section Options

| Option | Syntax | Purpose | Example |
|--------|--------|---------|---------|
| OnBootSec | `OnBootSec=<TIME>` | Defines the time to wait after boot before running the timer | `OnBootSec=15min` |
| OnStartupSec | `OnStartupSec=<TIME>` | Similar to OnBootSec, but counts from when the service manager was started | `OnStartupSec=20min` |
| OnActiveSec | `OnActiveSec=<TIME>` | Defines a timer relative to when the timer itself is activated | `OnActiveSec=30min` |
| OnUnitActiveSec | `OnUnitActiveSec=<TIME>` | Defines a timer relative to when the unit the timer is activating was last activated | `OnUnitActiveSec=1h` |
| OnUnitInactiveSec | `OnUnitInactiveSec=<TIME>` | Defines a timer relative to when the unit the timer is activating was last deactivated | `OnUnitInactiveSec=45min` |
| OnCalendar | `OnCalendar=<CALENDAR_SPEC>` | Defines real-time (i.e., wallclock) timers with calendar event expressions | `OnCalendar=Mon *-*-* 02:00:00` |
| AccuracySec | `AccuracySec=<TIME>` | Specifies the accuracy of the timer | `AccuracySec=1s` |
| RandomizedDelaySec | `RandomizedDelaySec=<TIME>` | Delays the timer by a randomly selected duration between 0 and the specified time value | `RandomizedDelaySec=30s` |
| Unit | `Unit=<SERVICE_UNIT>` | Specifies the unit to activate when this timer elapses | `Unit=backup.service` |
| Persistent | `Persistent=<BOOLEAN>` | If true, stores the time when the timer last elapsed | `Persistent=true` |
| WakeSystem | `WakeSystem=<BOOLEAN>` | If true, ensures that the system is resumed from suspend if it goes off while suspended | `WakeSystem=true` |
| RemainAfterElapse | `RemainAfterElapse=<BOOLEAN>` | If true, a timer will stay loaded after it has elapsed | `RemainAfterElapse=false` |
| Trigger | `Trigger=<BOOLEAN>` | If true, the timer will immediately trigger when activated | `Trigger=true` |

### Time Syntax
- `usec`, `ms`, `s`, `m`, `h`, `d`, `w`, `M`, `y`

### Calendar Spec Syntax
- `minutely`, `hourly`, `daily`, `weekly`, `monthly`, `yearly`
- `Mon,Tue *-*-* 00:00:00`
- `*-*-* 4:00:00`
- `*-*-1,15 00:00:00`

## [Install] Section Options

| Option | Syntax | Purpose | Example |
|--------|--------|---------|---------|
| WantedBy | `WantedBy=<TARGET>` | Specifies which target unit should want this timer if it's enabled | `WantedBy=timers.target` |
| RequiredBy | `RequiredBy=<TARGET>` | Similar to WantedBy, but creates a stronger dependency | `RequiredBy=multi-user.target` |
| Also | `Also=<UNIT>` | Specifies additional units to install/enable/disable along with this unit | `Also=backup-cleanup.timer` |
| Alias | `Alias=<NAME>` | Provides alternative names for this unit | `Alias=daily-backup.timer` |