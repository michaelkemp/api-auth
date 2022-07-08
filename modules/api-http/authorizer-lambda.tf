data "archive_file" "jwt_verifier_zip" {
  type        = "zip"
  output_path = "${path.module}/py-jwt-verifier.zip"
  source_dir  = "${path.module}/layers/py-jwt-verifier/"
}

resource "aws_lambda_layer_version" "jwt_verifier_layer" {
  filename            = "${path.module}/py-jwt-verifier.zip"
  layer_name          = "py-jwt-verifier"
  source_code_hash    = data.archive_file.jwt_verifier_zip.output_base64sha256
  compatible_runtimes = ["python3.7", "python3.8", "python3.9"]
}


data "archive_file" "authorizer_lambda_zip" {
  type             = "zip"
  source_dir       = "${path.module}/authorizer"
  output_path      = "${path.module}/authorizer.zip"
  output_file_mode = "0666"
}

resource "aws_lambda_function" "kempy-authorizer-lambda" {
  provider         = aws.region
  function_name    = "kempy-authorizer-lambda"
  description      = "HTTP API - Authorizer Lambda"
  filename         = data.archive_file.authorizer_lambda_zip.output_path
  source_code_hash = data.archive_file.authorizer_lambda_zip.output_base64sha256
  role             = aws_iam_role.kempy-authorizer-lambda-role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.9"
  timeout          = "30"
  layers = [
    aws_lambda_layer_version.jwt_verifier_layer.arn
  ]
}

resource "aws_cloudwatch_log_group" "kempy-authorizer-lambda-log" {
  provider          = aws.region
  name              = "/aws/lambda/kempy-authorizer-lambda"
  retention_in_days = 7
}

resource "aws_iam_role" "kempy-authorizer-lambda-role" {
  name               = "kempy-authorizer-lambda-role"
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
    name   = "kempy-authorizer-lambda-role-policy"
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
          }
        ]
      }
    EOF
  }
}
