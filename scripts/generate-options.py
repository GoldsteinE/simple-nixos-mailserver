import json
import sys

header = """
# Mailserver options

## `mailserver`

"""

template = """
`````{{option}} {key}
{description}

{type}
{default}
{example}
`````
"""

f = open(sys.argv[1])
options = json.load(f)

groups = ["mailserver.loginAccounts",
          "mailserver.certificate",
          "mailserver.dkim",
          "mailserver.dmarcReporting",
          "mailserver.fullTextSearch",
          "mailserver.redis",
          "mailserver.ldap",
          "mailserver.monitoring",
          "mailserver.backup",
          "mailserver.borgbackup"]

def render_option_value(opt, attr):
  if attr in opt:
      if isinstance(opt[attr], dict) and '_type' in opt[attr]:
          if opt[attr]['_type'] == 'literalExpression':
              if '\n' in opt[attr]['text']:
                  res = '\n```nix\n' + opt[attr]['text'].rstrip('\n') + '\n```'
              else:
                  res = '```{}```'.format(opt[attr]['text'])
          elif opt[attr]['_type'] == 'literalMD':
              res = opt[attr]['text']
      else:
          s = str(opt[attr])
          if s == "":
              res = '`""`'
          elif '\n' in s:
              res = '\n```\n' + s.rstrip('\n') + '\n```'
          else:
              res = '```{}```'.format(s)
      res = '- ' + attr + ': ' + res
  else:
      res = ""
  return res

def print_option(opt):
    if isinstance(opt['description'], dict) and '_type' in opt['description']: # mdDoc
        description = opt['description']['text']
    else:
        description = opt['description']
    print(template.format(
        key=opt['name'],
        description=description or "",
        type="- type: ```{}```".format(opt['type']),
        default=render_option_value(opt, 'default'),
        example=render_option_value(opt, 'example')))


print(header)
for opt in options:
    if any([opt['name'].startswith(c) for c in groups]):
        continue
    print_option(opt)

for c in groups:
    print('## `{}`'.format(c))
    print()
    for opt in options:
        if opt['name'].startswith(c):
            print_option(opt)
