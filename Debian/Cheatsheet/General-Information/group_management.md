# Group Management Commands Cheatsheet

## Create a new group
`groupadd groupname`
- With specific group ID: `groupadd -g 1500 groupname`

## Delete a group
`groupdel groupname`

## Modify a group
`groupmod [options] groupname`
- Change group name: `groupmod -n newname oldname`
- Change group ID: `groupmod -g 1500 groupname`

## Add user to a group
`usermod -aG groupname username`
- Add to multiple groups: `usermod -aG group1,group2 username`

## Remove user from a group
`gpasswd -d username groupname`

## Set primary group for a user
`usermod -g groupname username`

## List all groups
`cat /etc/group`

## List groups a user belongs to
`groups username`

## View detailed group information
`getent group groupname`

## Create a new system group
`groupadd -r groupname`

## Set or change group password
`gpasswd groupname`

## Remove group password
`gpasswd -r groupname`

## Add user as group administrator
`gpasswd -A username groupname`

## View group administrators
`gpasswd -A groupname`

## Change group ownership of a file
`chgrp groupname filename`

## Change group ownership recursively
`chgrp -R groupname directory`

## Find files belonging to a group
`find / -group groupname`

## Set default group for new files in a directory
`chmod g+s directory`

## Display group ID (GID) for a group
`getent group groupname | cut -d: -f3`

Remember to use these commands with caution, especially on production systems. Always follow your organization's security policies and best practices.