Contribute or troubleshoot
==========================

To report an issue, please go to
`<https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/issues>`_.

You can also chat with us on the Libera IRC channel ``#nixos-mailserver``.

Run NixOS tests
---------------

To run the test suite, you need to enable `Nix Flakes
<https://nixos.wiki/wiki/Flakes#Installing_flakes>`.

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

The documentation is written in RST, build with Sphinx and published
by `Read the Docs <https://readthedocs.org/>`_.

For the syntax, see `RST/Sphinx Cheatsheet
<https://sphinx-tutorial.readthedocs.io/cheatsheet/>`_.

The ``shell.nix`` provides all the tooling required to build the
documentation:

::

   $ nix-shell
   $ cd docs
   $ make html
   $ firefox ./_build/html/index.html

Note if you modify some NixOS mailserver options, you would also need
to regenerate the ``options.rst`` file:

::

   $ nix-shell --run generate-rst-options

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
