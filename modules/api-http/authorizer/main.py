
from py_jwt_verifier import PyJwtVerifier, PyJwtException
import json
import os
os.chdir("/tmp") ## required for SQLite

def lambda_handler(event, context):

    print(event)
    print(context)

    print("*** Authorization: {}".format(event["headers"]["authorization"]))

    auth = event["headers"]["authorization"]

    if auth.startswith("Bearer"):
        jwt = auth.split()[1]
        
        try:
            validator = PyJwtVerifier(jwt, auto_verify=False)
            payload = validator.verify(True)
            response = {
                "isAuthorized": True,
                "context": {
                    "JWT": "Valid"  
                }
            }
            print(payload)
            return response
        except PyJwtException as e:
            response = {
                "isAuthorized": False,
                "context": {
                    "PyJwtException": str(e)  
                }
            }
            print("Exception caught. Error: {}".format(e))
            return response
    
    response = {
        "isAuthorized": True,
        "context": {
            "test": "context"  
        }
    }

    return response
