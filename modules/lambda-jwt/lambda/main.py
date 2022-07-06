import json
import http.client
import boto3
from urllib.parse import urlparse

ssm = boto3.client("ssm",region_name="us-west-2")

def getToken():
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
    return data.decode("utf-8")


def lambda_handler(event, context):

    tokenData = json.loads(getToken())

    endpoint = ssm.get_parameter(Name="/kempy/api/endpoint")["Parameter"]["Value"]
    domain = urlparse(endpoint).netloc

    conn = http.client.HTTPSConnection(domain)
    headers = { "Authorization": "Bearer " + tokenData["access_token"] }
    conn.request("GET", "/jwt", "", headers)
    res = conn.getresponse()
    data = res.read()
    print(data.decode("utf-8"))

