import json
import sys
import re

header = """
Mailserver Options
==================

mailserver
~~~~~~~~~~

"""

template = """
{key}
{line}

{description}

{type}
{default}
"""

f = open(sys.argv[1])
options = json.load(f)

options = {k: v for k, v in options.items()
           if k.startswith("mailserver.")}

groups = ["mailserver.loginAccount",
          "mailserver.certificate",
          "mailserver.dkim",
          "mailserver.fullTextSearch",
          "mailserver.redis",
          "mailserver.monitoring",
          "mailserver.backup",
          "mailserver.borg"]


def print_option(name, value):
    if 'default' in value:
        if value['default'] == "":
            default = '``""``'
        elif isinstance(value['default'], dict) and '_type' in value['default']:
            if value['default']['_type'] == 'literalExpression':
                default = '``{}``'.format(value['default']['text'])
            if value['default']['_type'] == 'literalDocBook':
                default = value['default']['text']
        else:
            default = '``{}``'.format(value['default'])
        # Some default values contains OUTPUTPATHS which make the
        # output not stable across nixpkgs updates.
        default = re.sub('/nix/store/[\w.-]*/', '<OUTPUT-PATH>/', default)  # noqa
        default = '- Default: ' + default
    else:
        default = ""
    print(template.format(
        key=name,
        line="-"*len(name),
        description=value['description'],
        type="- Type: ``{}``".format(value['type']),
        default=default))


print(header)
for k, v in options.items():
    if any([k.startswith(c) for c in groups]):
        continue
    print_option(k, v)

for c in groups:
    print(c)
    print("~"*len(c))
    print()
    for k, v in options.items():
        if k.startswith(c):
            print_option(k, v)
