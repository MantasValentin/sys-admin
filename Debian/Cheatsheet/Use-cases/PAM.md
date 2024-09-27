# For password quality
sudo apt-get install libpam-pwquality libpam-cracklib

/etc/pam.d/common-password
or 
/etc/pam.d/system-auth

same can be done in /etc/security/pwquality.conf

# Password quality and policy enforcement
password    requisite     pam_pwquality.so retry=10 minlen=14 difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1 usercheck=1 dictcheck=1 gecoscheck=1

# Primary password processing
password    [success=2 default=ignore]  pam_unix.so obscure sha512 shadow try_first_pass use_authtok remember=5

# SSS (System Security Services) fallback
password    [success=1 default=ignore]  pam_sss.so use_authtok

# Deny if all previous modules fail
password    requisite     pam_deny.so

# Final permit (only reached if a module succeeded)
password    required      pam_permit.so




retry=3: Allows 3 attempts to enter a valid password. This balances security with user frustration.
minlen=14: Requires a minimum password length of 14 characters. This provides a good balance between security and memorability.
difok=3: Requires at least 3 characters to be different from the old password, preventing minor variations of the same password.
ucredit=-1, lcredit=-1, dcredit=-1, ocredit=-1: Requires at least one uppercase letter, one lowercase letter, one digit, and one special character. This ensures password complexity.
maxrepeat=3: Prevents more than 3 consecutive identical characters, avoiding easily guessable patterns.
usercheck=1: Checks if the password contains the username, preventing an obvious security weakness.
dictcheck=1: Checks the password against a dictionary, preventing common words from being used.
gecoscheck=1: Checks if the password contains GECOS field information.
enforce_for_root: Applies these rules to the root user as well, ensuring no accounts have weak passwords.
remember=5: Prevents reuse of the last 5 passwords, encouraging the creation of new, unique passwords.