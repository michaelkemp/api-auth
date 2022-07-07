
# env.sh
#   #!/bin/sh
#   cat <<EOF
#   {
#     "domain":        "xxxx.us.auth0.com",
#     "client_id":     "xxxx",
#     "client_secret": "xxxx",
#     "audience":      "https://auth0-jwt-authorizer",
#     "grant_type":    "client_credentials"
#   }
#   EOF

data "external" "env" {
  program = ["${path.module}/env.sh"]
}

resource "aws_ssm_parameter" "domain" {
  name     = "/kempy/auth0/domain"
  type     = "SecureString"
  value    = data.external.env.result["domain"]
  provider = aws.region
}
resource "aws_ssm_parameter" "client_id" {
  name     = "/kempy/auth0/client_id"
  type     = "SecureString"
  value    = data.external.env.result["client_id"]
  provider = aws.region
}
resource "aws_ssm_parameter" "client_secret" {
  name     = "/kempy/auth0/client_secret"
  type     = "SecureString"
  value    = data.external.env.result["client_secret"]
  provider = aws.region
}
resource "aws_ssm_parameter" "audience" {
  name     = "/kempy/auth0/audience"
  type     = "SecureString"
  value    = data.external.env.result["audience"]
  provider = aws.region
}
resource "aws_ssm_parameter" "grant_type" {
  name     = "/kempy/auth0/grant_type"
  type     = "SecureString"
  value    = data.external.env.result["grant_type"]
  provider = aws.region
}

data "archive_file" "lambda_zip" {
  type             = "zip"
  source_dir       = "${path.module}/lambda"
  output_path      = "${path.module}/lambda.zip"
  output_file_mode = "0666"
}

resource "aws_lambda_function" "kempy-call-jwt-api-lambda" {
  provider         = aws.region
  function_name    = "kempy-call-jwt-api-lambda"
  description      = "HTTP API - Test JWT Lambda"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.kempy-call-jwt-api-lambda-role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.9"
  timeout          = "30"
}

resource "aws_cloudwatch_log_group" "kempy-call-jwt-api-lambda-log" {
  provider          = aws.region
  name              = "/aws/lambda/kempy-call-jwt-api-lambda"
  retention_in_days = 7
}

resource "aws_iam_role" "kempy-call-jwt-api-lambda-role" {
  name               = "kempy-call-jwt-api-lambda-role"
  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }    
  EOF
  inline_policy {
    name   = "kempy-call-jwt-api-lambda-role-policy"
    policy = <<-EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Action": [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*",
            "Effect": "Allow"
          },
          {
              "Effect": "Allow",
              "Action": [
                  "ssm:PutParameter",
                  "ssm:DeleteParameter",
                  "ssm:GetParameterHistory",
                  "ssm:GetParametersByPath",
                  "ssm:GetParameters",
                  "ssm:GetParameter",
                  "ssm:DeleteParameters"
              ],
              "Resource": [
                  "arn:aws:ssm:us-west-2:847068433460:parameter/kempy/*"
              ]
          }          
        ]
      }
    EOF
  }
}
