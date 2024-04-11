# ![Simple Nixos MailServer][logo]
![license](https://img.shields.io/badge/license-GPL3-brightgreen.svg)
[![pipeline status](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/badges/master/pipeline.svg)](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/commits/master)


## Release branches

For each NixOS release, we publish a branch. You then have to use the
SNM branch corresponding to your NixOS version.

* For NixOS 23.11
   - Use the [SNM branch `nixos-23.11`](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/tree/nixos-23.11)
   - [Documentation](https://nixos-mailserver.readthedocs.io/en/nixos-23.11/)
   - [Release notes](https://nixos-mailserver.readthedocs.io/en/nixos-23.11/release-notes.html#nixos-23-11)
* For NixOS 23.05
   - Use the [SNM branch `nixos-23.05`](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/tree/nixos-23.05)
   - [Documentation](https://nixos-mailserver.readthedocs.io/en/nixos-23.05/)
   - [Release notes](https://nixos-mailserver.readthedocs.io/en/nixos-23.05/release-notes.html#nixos-23-05)
* For NixOS unstable
   - Use the [SNM branch `master`](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/tree/master)
   - [Documentation](https://nixos-mailserver.readthedocs.io/en/latest/)

[Subscribe to SNM Announcement List](https://www.freelists.org/list/snm)
This is a very low volume list where new releases of SNM are announced, so you
can stay up to date with bug fixes and updates.


## Features
### v2.0
 * [x] Continous Integration Testing
 * [x] Multiple Domains
 * Postfix MTA
    - [x] smtp on port 25
    - [x] submission tls on port 465
    - [x] submission starttls on port 587
    - [x] lmtp with dovecot
 * Dovecot
    - [x] maildir folders
    - [x] imap with tls on port 993
    - [x] pop3 with tls on port 995
    - [x] imap with starttls on port 143
    - [x] pop3 with starttls on port 110
 * Certificates
    - [x] manual certificates
    - [x] on the fly creation
    - [x] Let's Encrypt
 * Spam Filtering
    - [x] via rspamd
 * Virus Scanning
    - [x] via clamav
 * DKIM Signing
    - [x] via opendkim
 * User Management
    - [x] declarative user management
    - [x] declarative password management
 * Sieves
    - [x] A simple standard script that moves spam
    - [x] Allow user defined sieve scripts
    - [x] ManageSieve support
 * User Aliases
    - [x] Regular aliases
    - [x] Catch all aliases

### In the future

  * DKIM Signing
    - [ ] Allow a per domain selector

### Get in touch

- Subscribe to the [mailing list](https://www.freelists.org/archive/snm/)
- Join the Libera Chat IRC channel `#nixos-mailserver`

## How to Set Up a 10/10 Mail Server Guide

Check out the [Setup Guide](https://nixos-mailserver.readthedocs.io/en/latest/setup-guide.html) in the project's documentation.

For a complete list of options, [see in readthedocs](https://nixos-mailserver.readthedocs.io/en/latest/options.html).

## Development

See the [How to Develop SNM](https://nixos-mailserver.readthedocs.io/en/latest/howto-develop.html) documentation page.

## Contributors
See the [contributor tab](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/graphs/master)

### Alternative Implementations
 * [NixCloud Webservices](https://github.com/nixcloud/nixcloud-webservices)

### Credits
 * send mail graphic by [tnp_dreamingmao](https://thenounproject.com/dreamingmao)
   from [TheNounProject](https://thenounproject.com/) is licensed under
   [CC BY 3.0](http://creativecommons.org/~/3.0/)
 * Logo made with [Logomakr.com](https://logomakr.com)


[logo]: docs/logo.png
