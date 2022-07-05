
module "api-http-oregon" {
  source               = "../../modules/api-http"
  providers = {
    aws.region = aws.us-west-2
  }
}
