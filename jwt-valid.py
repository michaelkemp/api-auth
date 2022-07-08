#!/usr/bin/env python3

# pip install py-jwt-verifier
from py_jwt_verifier import PyJwtVerifier, PyJwtException
import sys, os

# Disable
def blockPrint():
    sys.stdout = open(os.devnull, 'w')

# Restore
def enablePrint():
    sys.stdout = sys.__stdout__


jwt = ""


validator = PyJwtVerifier(jwt, auto_verify=False)

try:
    blockPrint()
    payload = validator.verify(True)
    enablePrint()
    print(payload)
except PyJwtException as e:
    print(f"Exception caught. Error: {e}")



# import jwt
# import base64
# import json

# token = "xxxx"

# header, payload, signature = token.split(".")

# header_padding = len(header) % 4
# header += "="* (4 - header_padding)

# payload_padding = len(payload) % 4
# payload += "="* (4 - payload_padding)

# headerData = json.loads(base64.b64decode(header).decode("utf-8"))
# payloadData = json.loads(base64.b64decode(payload).decode("utf-8"))

# print( json.dumps(headerData, indent=4) )
# print( json.dumps(payloadData, indent=4) )
# print(signature)

# # jwt.decode(token, key='my_super_secret', algorithms=['HS256', ])

# # ## https://xxxxx.us.auth0.com/.well-known/jwks.json