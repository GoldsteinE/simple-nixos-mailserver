Contribute or troubleshoot
==========================

To report an issue, please go to
`<https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/issues>`_.

You can also chat with us on the Libera IRC channel ``#nixos-mailserver``.

Run NixOS tests
---------------

To run the test suite, you need to enable `Nix Flakes
<https://nixos.wiki/wiki/Flakes#Installing_flakes>`_.

You can then run the testsuite via

::

   $ nix flake check -L

Since Nix doesn't garantee your machine have enough resources to run
all test VMs in parallel, some tests can fail. You would then haev to
run tests manually. For instance:

::

   $ nix build .#hydraJobs.x86_64-linux.external-unstable -L


Contributing to the documentation
---------------------------------

The documentation is written in RST (except option documentation which is in CommonMark),
built with Sphinx and published by `Read the Docs <https://readthedocs.org/>`_.

For the syntax, see the `RST/Sphinx primer
<https://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html>`_.

To build the documentation, you need to enable `Nix Flakes
<https://nixos.wiki/wiki/Flakes#Installing_flakes>`_.


::

   $ nix build .#documentation
   $ xdg-open result/index.html

Nixops
------

You can test the setup via ``nixops``. After installation, do

::

   $ nixops create nixops/single-server.nix nixops/vbox.nix -d mail
   $ nixops deploy -d mail
   $ nixops info -d mail

You can then test the server via e.g. \ ``telnet``. To log into it, use

::

   $ nixops ssh -d mail mailserver

Imap
----

To test imap manually use

::

   $ openssl s_client -host mail.example.com -port 143 -starttls imap
