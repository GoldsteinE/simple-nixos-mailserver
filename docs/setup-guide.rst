Setup Guide
===========

Mail servers can be a tricky thing to set up. This guide is supposed to
run you through the most important steps to achieve a 10/10 score on
`<https://mail-tester.com>`_.

What you need is:

- a server running NixOS with a public IP
- a domain name.

.. note::

   In the following, we consider a server with the public IP ``1.2.3.4``
   and the domain ``example.com``.

First, we will set the minimum DNS configuration to be able to deploy
an up and running mail server. Once the server is deployed, we could
then set all DNS entries required to send and receive mails on this
server.

Setup DNS A record for server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Add a DNS record to the domain ``example.com`` with the following
entries

==================== ===== ==== =============
Name (Subdomain)     TTL   Type Value
==================== ===== ==== =============
``mail.example.com`` 10800 A    ``1.2.3.4``
==================== ===== ==== =============

You can check this with

::

   $ ping mail.example.com
   64 bytes from mail.example.com (1.2.3.4): icmp_seq=1 ttl=46 time=21.3 ms
   ...

Note that it can take a while until a DNS entry is propagated. This
DNS entry is required for the Let's Encrypt certificate generation
(which is used in the below configuration example).

Setup the server
~~~~~~~~~~~~~~~~

The following describes a server setup that is fairly complete. Even
though there are more possible options (see the ``default.nix`` file),
these should be the most common ones.

.. code:: nix

   { config, pkgs, ... }:
   {
     imports = [
       (builtins.fetchTarball {
         # Pick a commit from the branch you are interested in
         url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/A-COMMIT-ID/nixos-mailserver-A-COMMIT-ID.tar.gz";
         # And set its hash
         sha256 = "0000000000000000000000000000000000000000000000000000";
       })
     ];

     mailserver = {
       enable = true;
       fqdn = "mail.example.com";
       domains = [ "example.com" ];

       # A list of all login accounts. To create the password hashes, use
       # nix run nixpkgs.apacheHttpd -c htpasswd -nbB "" "super secret password" | cut -d: -f2
       loginAccounts = {
           "user1@example.com" = {
               hashedPasswordFile = "/a/file/containing/a/hashed/password";
               aliases = ["postmaster@example.com"];
           };
           "user2@example.com" = { ... };
       };

       # Use Let's Encrypt certificates. Note that this needs to set up a stripped
       # down nginx and opens port 80.
       certificateScheme = 3;
     };
   }

After a ``nixos-rebuild switch`` your server should be running all
mail components.

Setup all other DNS requirements
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Set rDNS (reverse DNS) entry for server
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Wherever you have rented your server, you should be able to set reverse
DNS entries for the IP’s you own. Add an entry resolving ``1.2.3.4``
to ``mail.example.com``

You can check this with

::

   $ nix-shell -p bind --command "host 1.2.3.4"
   4.3.2.1.in-addr.arpa domain name pointer mail.example.com.

Note that it can take a while until a DNS entry is propagated.

Set a ``MX`` record
^^^^^^^^^^^^^^^^^^^


Add a ``MX`` record to the domain ``example.com``.

================ ==== ======== =================
Name (Subdomain) Type Priority Value
================ ==== ======== =================
example.com      MX   10       mail.example.com
================ ==== ======== =================

You can check this with

::

   $ nix-shell -p bind --command "host -t mx example.com"
   example.com mail is handled by 10 mail.example.com.

Note that it can take a while until a DNS entry is propagated.

Set a ``SPF`` record
^^^^^^^^^^^^^^^^^^^^

Add a `SPF <https://en.wikipedia.org/wiki/Sender_Policy_Framework>`_
record to the domain ``example.com``.

================ ===== ==== ================================
Name (Subdomain) TTL   Type Value
================ ===== ==== ================================
example.com      10800 TXT  `v=spf1 a:mail.example.com -all`
================ ===== ==== ================================

You can check this with

::

   $ nix-shell -p bind --command "host -t TXT example.com"
   example.com descriptive text "v=spf1 a:mail.example.com -all"

Note that it can take a while until a DNS entry is propagated.

Set ``DKIM`` signature
^^^^^^^^^^^^^^^^^^^^^^

On your server, the ``opendkim`` systemd service generated a file
containing your DKIM public key in the file
``/var/dkim/example.com.mail.txt``. The content of this file looks
like

::

   mail._domainkey IN TXT "v=DKIM1; k=rsa; s=email; p=<really-long-key>" ; ----- DKIM mail for domain.tld

where ``really-long-key`` is your public key.

Based on the content of this file, we can add a ``DKIM`` record to the
domain ``example.com``.

=========================== ===== ==== ==============================
Name (Subdomain)            TTL   Type Value
=========================== ===== ==== ==============================
mail._domainkey.example.com 10800 TXT  ``v=DKIM1; p=<really-long-key>``
=========================== ===== ==== ==============================

You can check this with

::

   $ nix-shell -p bind --command "host -t txt mail._domainkey.example.com"
   mail._domainkey.example.com descriptive text "v=DKIM1;p=<really-long-key>"

Note that it can take a while until a DNS entry is propagated.

Set a ``DMARC`` record
^^^^^^^^^^^^^^^^^^^^^^

Add a ``DMARC`` record to the domain ``example.com``.

======================== ===== ==== ====================
Name (Subdomain)         TTL   Type Value
======================== ===== ==== ====================
_dmarc.example.com       10800 TXT  ``v=DMARC1; p=none``
======================== ===== ==== ====================

You can check this with

::

   $ nix-shell -p bind --command "host -t TXT _dmarc.example.com"
   _dmarc.example.com descriptive text "v=DMARC1; p=none"

Note that it can take a while until a DNS entry is propagated.


Test your Setup
~~~~~~~~~~~~~~~

Write an email to your aunt (who has been waiting for your reply far too
long), and sign up for some of the finest newsletters the Internet has.
Maybe you want to sign up for the `SNM Announcement
List <https://www.freelists.org/list/snm>`__?

Besides that, you can send an email to
`mail-tester.com <https://www.mail-tester.com/>`__ and see how you
score, and let `mxtoolbox.com <http://mxtoolbox.com/>`__ take a look at
your setup, but if you followed the steps closely then everything should
be awesome!
