
module "api-http-oregon" {
  source               = "../../modules/api-http"
  providers = {
    aws.region = aws.us-west-2
  }
}

module "user-oregon" {
  source               = "../../modules/user"
  providers = {
    aws.region = aws.us-west-2
  }
}

## IAM Auth - AWS IAM v4 
## Key ID: SSM /kempy/user/id
## Secret: SSM /kempy/user/secret
## Region: us-east-1 
## Service: execute-api

## JWT Auth - Bearer
## get token from Auth0

