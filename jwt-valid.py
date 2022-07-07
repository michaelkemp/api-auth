#!/usr/bin/env python3

import jwt
import base64
import json

token = "xxxx"

header, payload, signature = token.split(".")

header_padding = len(header) % 4
header += "="* (4 - header_padding)

payload_padding = len(payload) % 4
payload += "="* (4 - payload_padding)

headerData = json.loads(base64.b64decode(header).decode("utf-8"))
payloadData = json.loads(base64.b64decode(payload).decode("utf-8"))

print( json.dumps(headerData, indent=4) )
print( json.dumps(payloadData, indent=4) )
print(signature)

# jwt.decode(token, key='my_super_secret', algorithms=['HS256', ])

# ## https://xxxxx.us.auth0.com/.well-known/jwks.json