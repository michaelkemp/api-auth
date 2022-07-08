#!/usr/bin/env python3

# https://pypi.org/project/py-jwt-verifier/
# pip3 install py-jwt-verifier
# pip3 install --target . py-jwt-verifier

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

