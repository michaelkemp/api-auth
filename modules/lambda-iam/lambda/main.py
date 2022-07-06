import boto3
from botocore.awsrequest import AWSRequest
from botocore.endpoint import URLLib3Session
from botocore.auth import SigV4Auth

ssm = boto3.client("ssm",region_name="us-west-2")

def signed_request(creds, method, url, data=None, params=None, headers=None):
    request = AWSRequest(method=method, url=url, data=data, params=params, headers=headers)
    SigV4Auth(creds, "execute-api", 'us-east-1').add_auth(request)
    session = URLLib3Session()
    r = session.send(request.prepare())
    return r.content.decode('utf-8')

def lambda_handler(event, context):
    session = boto3.Session()
    creds = session.get_credentials().get_frozen_credentials()

    endpoint = ssm.get_parameter(Name="/kempy/api/endpoint")["Parameter"]["Value"]

    url = endpoint + "/iam"
    print(url)
    headers = {'Content-Type': 'application/x-amz-json-1.1'}
    response = signed_request(creds = creds, method='GET', url=url, headers=headers)

    print(response)
