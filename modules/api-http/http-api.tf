
resource "aws_apigatewayv2_api" "kempy-http-api" {
  name          = "kempy-http-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }
  provider = aws.region
}

resource "aws_lambda_permission" "apigw" {
  provider      = aws.region
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.kempy-api-http-lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.kempy-http-api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "default-stage" {
  api_id      = aws_apigatewayv2_api.kempy-http-api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "aws_proxy_integration" {
  api_id             = aws_apigatewayv2_api.kempy-http-api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.kempy-api-http-lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "get_root" {
  api_id    = aws_apigatewayv2_api.kempy-http-api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.aws_proxy_integration.id}"
}

resource "aws_apigatewayv2_route" "get_iam" {
  api_id             = aws_apigatewayv2_api.kempy-http-api.id
  route_key          = "GET /iam"
  target             = "integrations/${aws_apigatewayv2_integration.aws_proxy_integration.id}"
  authorization_type = "AWS_IAM"
}


resource "aws_apigatewayv2_authorizer" "auth0" {
  api_id           = aws_apigatewayv2_api.kempy-http-api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "kempy-auth0"

  jwt_configuration {
    audience = ["https://auth0-jwt-authorizer"]
    issuer   = "https://dev-74vf6lqe.us.auth0.com/"
  }
}

resource "aws_apigatewayv2_route" "get_jwt" {
  api_id             = aws_apigatewayv2_api.kempy-http-api.id
  route_key          = "GET /jwt"
  target             = "integrations/${aws_apigatewayv2_integration.aws_proxy_integration.id}"
  authorizer_id      = aws_apigatewayv2_authorizer.auth0.id
  authorization_type = "JWT"
}

resource "aws_ssm_parameter" "domain" {
  name     = "/kempy/api/endpoint"
  type     = "String"
  value    = aws_apigatewayv2_api.kempy-http-api.api_endpoint
  provider = aws.region
}

