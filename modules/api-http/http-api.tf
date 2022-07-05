
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
  api_id             = aws_apigatewayv2_api.kempy-http-api.id
  route_key          = "GET /"
  target             = "integrations/${aws_apigatewayv2_integration.aws_proxy_integration.id}"
}
