Full text search
==========================

By default, when your IMAP client searches for an email containing some
text in its *body*, dovecot will read all your email sequentially. This
is very slow and IO intensive. To speed body searches up, it is possible to
*index* emails with a plugin to dovecot, ``fts_xapian``.

Enabling full text search
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To enable indexing for full text search here is an example configuration.

.. code:: nix

  {
    mailserver = {
      # ...
      fullTextSearch = {
        enable = true;
        # index new email as they arrive
        autoIndex = true;
        # this only applies to plain text attachments, binary attachments are never indexed
        indexAttachments = true;
        enforced = "body";
      };
    };
  }


The ``enforced`` parameter tells dovecot to fail any body search query that cannot
use an index. This prevents dovecot to fall back to the IO-intensive brute
force search.

If you set ``autoIndex`` to ``false``, indices will be created when the IMAP client
issues a search query, so latency will be high.

Resource requirements
~~~~~~~~~~~~~~~~~~~~~~~~

Indices created by the full text search feature can take more disk
space than the emails themselves. By default, they are kept in the
emails location. When enabling the full text search feature, it is
recommended to move indices in a different location, such as
(``/var/lib/dovecot/indices``) by using the option
``mailserver.indexDir``.

.. warning::

   When the value of the ``indexDir`` option is changed, all dovecot
   indices needs to be recreated: clients would need to resynchronize.

Indexation itself is rather resouces intensive, in CPU, and for emails with
large headers, in memory as well. Initial indexation of existing emails can take
hours. If the indexer worker is killed or segfaults during indexation, it can
be that it tried to allocate more memory than allowed. You can increase the memory
limit by eg ``mailserver.fullTextSearch.memoryLimit = 2000`` (in MiB).

Mitigating resources requirements
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can:

* disable indexation of attachements ``mailserver.fullTextSearch.indexAttachments = false``
* reduce the size of ngrams to be indexed ``mailserver.fullTextSearch.minSize`` and ``maxSize``
* disable automatic indexation for some folders with
  ``mailserver.fullTextSearch.autoIndexExclude``.  Folders can be specified by
  name (``"Trash"``), by special use (``"\\Junk"``) or with a wildcard.

