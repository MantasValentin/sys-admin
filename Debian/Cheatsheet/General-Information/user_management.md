# User Management Commands Cheatsheet

## Add a new user
`useradd username`
- With home directory: `useradd -m username`
- Specify home directory: `useradd -m -d /path/to/home username`
- With specific user ID: `useradd -u 1500 username`
- With specific shell: `useradd -s /bin/bash username`

## Delete a user
`userdel username`
- Delete user and home directory: `userdel -r username`

## Modify user account
`usermod [options] username`
- Change username: `usermod -l newname oldname`
- Change user's home directory: `usermod -d /new/home username`
- Change user ID: `usermod -u 1500 username`

## Add user to a group
`usermod -aG groupname username`

## Remove user from a group
`gpasswd -d username groupname`

## Lock a user account
`usermod -L username`

## Unlock a user account
`usermod -U username`

## Set user's login shell
`usermod -s /bin/bash username`

## Create a new group
`groupadd groupname`

## Delete a group
`groupdel groupname`

## Modify a group
`groupmod [options] groupname`
- Change group name: `groupmod -n newname oldname`
- Change group ID: `groupmod -g 1500 groupname`

## View user information
`id username`

## List all users
`cat /etc/passwd`

## List all groups
`cat /etc/group`

## View users currently logged in
`who`

## View last logins
`last`

## Switch to another user
`su - username`

## Execute command as another user
`sudo -u username command`

## Set user expiration date
`usermod -e YYYY-MM-DD username`

Remember to use these commands with caution, especially on production systems. Always follow your organization's security policies and best practices.