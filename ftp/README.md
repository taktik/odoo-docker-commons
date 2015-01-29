# Vsftpd

This will install vsftpd.
You can tweak or override the vsftpd.conf.

Our default values are:

    * Chroot everyone
    * Disable anonymous
    * Allow only users in allowed_users file.

To allow some users, add them to the /etc/vsftpd.allowed_users file.