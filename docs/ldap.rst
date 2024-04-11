LDAP Support
============

It is possible to manage mail user accounts with LDAP rather than with
the option `loginAccounts <options.html#mailserver-loginaccounts>`_.

All related LDAP options are described in the `LDAP options section
<options.html#mailserver-ldap>`_ and the `LDAP test
<https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/blob/master/tests/ldap.nix>`_
provides a getting started example.

.. note::
   The LDAP support can not be enabled if some accounts are also defined with ``mailserver.loginAccounts``.

