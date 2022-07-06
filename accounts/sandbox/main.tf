
module "api-http-oregon" {
  source = "../../modules/api-http"
  providers = {
    aws.region = aws.us-west-2
  }
}

module "lambda-iam-oregon" {
  source = "../../modules/lambda-iam"
  providers = {
    aws.region = aws.us-west-2
  }
}

module "lambda-jwt-oregon" {
  source = "../../modules/lambda-jwt"
  providers = {
    aws.region = aws.us-west-2
  }
}
