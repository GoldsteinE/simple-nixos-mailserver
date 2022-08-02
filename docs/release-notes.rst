Release Notes
=============

NixOS 22.05
-----------

- Make NixOS Mailserver options discoverable from search.nixos.org
- Add a roundcube setup guide in the documentation

NixOS 21.11
-----------

- Switch default DKIM body policy from simple to relaxed
  (`merge request <https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/merge_requests/247>`__)
- Ensure locally-delivered mails have the X-Original-To header
  (`merge request <https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/merge_requests/243>`__)
- NixOS Mailserver options are detailed in the `documentation
  <https://nixos-mailserver.readthedocs.io/en/latest/options.html>`__
- New options ``dkimBodyCanonicalization`` and
  ``dkimHeaderCanonicalization``
- New option ``certificateDomains`` to generate certificate for
  additional domains (such as ``imap.example.com``)


NixOS 21.05
-----------

- New `fullTextSearch` option to search in messages (based on Xapian)
  (`Merge Request <https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/merge_requests/212>`__)
- Flake support
  (`Merge Request <https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/merge_requests/200>`__)
- New `openFirewall` option defaulting to `true`
- We moved from Freenode to Libera Chat

NixOS 20.09
-----------

- IMAP and Submission with TLS wrapped-mode are now enabled by default
  on ports 993 and 465 respectively
- OpenDKIM is now sandboxed with Systemd
- New `forwards` option to forwards emails to external addresses
  (`Merge Request <https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/merge_requests/193>`__)
- New `sendingFqdn` option to specify the fqdn of the machine sending
  email (`Merge Request <https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/merge_requests/187>`__)
- Move the Gitlab wiki to `ReadTheDocs
  <https://nixos-mailserver.readthedocs.io/en/latest/>`_
