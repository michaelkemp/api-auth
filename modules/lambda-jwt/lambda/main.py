import json
import http.client
import boto3
from urllib.parse import urlparse
import time

ssm = boto3.client("ssm",region_name="us-west-2")
rightnow = int(time.time())

def getToken():
    print("+++++++++++++++++++++++ GETTING NEW TOKEN +++++++++++++++++++++++")
    domain = ssm.get_parameter(Name="/kempy/auth0/domain", WithDecryption=True)["Parameter"]["Value"]
    client_id = ssm.get_parameter(Name="/kempy/auth0/client_id", WithDecryption=True)["Parameter"]["Value"]
    client_secret = ssm.get_parameter(Name="/kempy/auth0/client_secret", WithDecryption=True)["Parameter"]["Value"]
    audience = ssm.get_parameter(Name="/kempy/auth0/audience", WithDecryption=True)["Parameter"]["Value"]
    grant_type = ssm.get_parameter(Name="/kempy/auth0/grant_type", WithDecryption=True)["Parameter"]["Value"]

    conn = http.client.HTTPSConnection(domain)
    payload = { "client_id": client_id, "client_secret": client_secret, "audience": audience, "grant_type": grant_type }
    headers = { "content-type": "application/json" }
    conn.request("POST", "/oauth/token", json.dumps(payload), headers)
    res = conn.getresponse()
    data = res.read()

    tokenData = json.loads(data.decode("utf-8"))
    jwtToken = tokenData["access_token"]
    jwtTokenDate = rightnow + int(tokenData["expires_in"])
    ssm.put_parameter(Name="/kempy/auth0/jwtToken", Value=str(jwtToken), Type="SecureString", Overwrite=True, Tier='Standard', DataType='text')
    ssm.put_parameter(Name="/kempy/auth0/jwtTokenDate", Value=str(jwtTokenDate), Type="SecureString", Overwrite=True, Tier='Standard', DataType='text')

    return jwtToken, jwtTokenDate


def lambda_handler(event, context):

    print(event)
    print(context)
    
    print("rightnow: {}".format(rightnow))
    
    try:
        jwtToken = ssm.get_parameter(Name="/kempy/auth0/jwtToken", WithDecryption=True)["Parameter"]["Value"]
        jwtTokenDate = ssm.get_parameter(Name="/kempy/auth0/jwtTokenDate", WithDecryption=True)["Parameter"]["Value"]
    except Exception as e:
        print("The error: {}".format(e))
        jwtToken, jwtTokenDate = getToken()
    
    secondsLeft = int(jwtTokenDate) - rightnow
    print("Seconds Left: {}".format(secondsLeft))
    if secondsLeft < 10000:
        jwtToken, jwtTokenDate = getToken()
        
    endpoint = ssm.get_parameter(Name="/kempy/api/endpoint")["Parameter"]["Value"]
    domain = urlparse(endpoint).netloc

    conn = http.client.HTTPSConnection(domain)
    headers = { "Authorization": "Bearer " + jwtToken }
    ## conn.request("GET", "/jwt", "", headers)
    conn.request("GET", "/lambda", "", headers) ## Try Lambda Auth Handler
    
    res = conn.getresponse()
    data = res.read()
    print(data.decode("utf-8"))

