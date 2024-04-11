Autodiscovery
=============

`RFC6186 <https://www.rfc-editor.org/rfc/rfc6186>`_ allows supporting email clients to automatically discover SMTP / IMAP addresses
of the mailserver. For that, the following records are required:

================= ==== ==== ======== ====== ==== =================
Record            TTL  Type Priority Weight Port Value
================= ==== ==== ======== ====== ==== =================
_submission._tcp  3600 SRV  5        0      587  mail.example.com.
_submissions._tcp 3600 SRV  5        0      465  mail.example.com.
_imap._tcp        3600 SRV  5        0      143  mail.example.com.
_imaps._tcp       3600 SRV  5        0      993  mail.example.com.
================= ==== ==== ======== ====== ==== =================

Please note that only a few MUAs currently implement this. For vendor-specific
discovery mechanisms `automx <https://github.com/rseichter/automx2>`_ can be used instead.

