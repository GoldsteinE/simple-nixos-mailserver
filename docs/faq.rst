FAQ
===

``catchAll`` users can't send email as user other than themself
---------------------------------------------------------------

To allow a ``catchAll`` user to send mail with the address used as
recipient, the option ``aliases`` has to be used instead of ``catchAll``.

For instance, to allow ``user@example.com`` to catch all mails to the
domain ``example.com`` and send mails with any address of this domain:


.. code:: nix

    mailserver.loginAccounts = {
        "user@example.com" = {
            aliases = [ "@example.com" ];
        };
    };

See also `this discussion <https://github.com/r-raymond/nixos-mailserver/issues/49>`__ for details.
