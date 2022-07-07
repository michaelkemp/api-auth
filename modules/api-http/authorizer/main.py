import json

def lambda_handler(event, context):

    print(event)
    print(context)

    print("*** Authorization: {}".format(event["headers"]["authorization"]))
    
    response = {
        "isAuthorized": True,
        "context": {
            "test": "context"  
        }
    }

    return response
