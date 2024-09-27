Certainly. Here's a cheatsheet for permission management in Unix-like systems:

1. Change file/directory permissions:
```
chmod [options] mode file/directory
```

2. Change file/directory owner:
```
chown [options] user:group file/directory
```

3. Change group ownership:
```
chgrp [options] group file/directory
```

4. Set default permissions for new files/directories:
```
umask [mask]
```

5. View file/directory permissions:
```
ls -l file/directory
```

6. View permissions in octal format:
```
stat -c "%a %n" file/directory
```

7. Recursively change permissions:
```
chmod -R [mode] directory
```

8. Add execute permission:
```
chmod +x file
```

9. Remove write permission:
```
chmod -w file
```

10. Set SUID permission:
```
chmod u+s file
```

11. Set SGID permission:
```
chmod g+s directory
```

12. Set sticky bit:
```
chmod +t directory
```

13. Copy permissions from one file to another:
```
chmod --reference=source_file target_file
```

14. Change ownership recursively:
```
chown -R user:group directory
```

15. View extended file attributes:
```
getfacl file
```

16. Set extended file attributes:
```
setfacl -m u:user:rwx file
```

17. Remove extended file attributes:
```
setfacl -x u:user file
```

18. Find files with specific permissions:
```
find /path -perm mode
```

19. Find SUID files:
```
find /path -perm /4000
```

20. Find world-writable files:
```
find /path -perm -2 -type f
```

Common permission modes:
- 755 (rwxr-xr-x): Commonly used for directories
- 644 (rw-r--r--): Commonly used for regular files
- 700 (rwx------): Private directories/files

Remember:
- r (read) = 4
- w (write) = 2
- x (execute) = 1

Would you like me to explain any of these commands in more detail or provide additional information about permission management?