data "archive_file" "lambda_zip" {
  type             = "zip"
  source_dir       = "${path.module}/lambda"
  output_path      = "${path.module}/lambda.zip"
  output_file_mode = "0666"
}

resource "aws_lambda_function" "kempy-api-http-lambda" {
  provider         = aws.region
  function_name    = "kempy-api-http-lambda"
  description      = "HTTP API - Test Lambda"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.kempy-api-http-lambda-role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.9"
  timeout          = "30"
}

resource "aws_cloudwatch_log_group" "kempy-api-http-lambda-log" {
  provider          = aws.region
  name              = "/aws/lambda/kempy-api-http-lambda"
  retention_in_days = 7
}

resource "aws_iam_role" "kempy-api-http-lambda-role" {
  name                 = "kempy-api-http-lambda-role"
  assume_role_policy   = <<-EOF
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
    name   = "kempy-http-lambda-role-policy"
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
