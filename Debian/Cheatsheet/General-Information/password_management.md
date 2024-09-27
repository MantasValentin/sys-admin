# Password Administration Commands Cheatsheet

## Change a user's password
- As root: `passwd username`
- As the user: `passwd`

## Force a user to change password at next login
`chage -d 0 username`

## Set password expiration
`chage -M days username`

## Lock a user account
`passwd -l username` or `usermod -L username`

## Unlock a user account
`passwd -u username` or `usermod -U username`

## Set a user's password to expire
`chage -E YYYY-MM-DD username`

## View password status for a user
`passwd -S username`

## View detailed password information
`chage -l username`

## Set minimum password age
`chage -m days username`

## Set maximum password age
`chage -M days username`

## Add a new user with password
`useradd -m username && passwd username`

## Change password policies (in /etc/login.defs)
- Edit the file: `sudo nano /etc/login.defs`
- Look for and modify these lines:
  ```
  PASS_MAX_DAYS 90
  PASS_MIN_DAYS 7
  PASS_WARN_AGE 7
  ```

## Check password quality
- Install: `sudo apt-get install libpam-pwquality`
- Edit: `sudo nano /etc/security/pwquality.conf`

## View last password change
`grep username /etc/shadow | cut -d: -f3`

## Reset a user's failed login count
`faillog -r -u username`

Remember to use these commands with caution, especially on production systems. Always follow your organization's security policies and best practices.