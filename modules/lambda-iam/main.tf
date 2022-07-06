data "archive_file" "lambda_zip" {
  type             = "zip"
  source_dir       = "${path.module}/lambda"
  output_path      = "${path.module}/lambda.zip"
  output_file_mode = "0666"
}

resource "aws_lambda_function" "kempy-call-iam-api-lambda" {
  provider         = aws.region
  function_name    = "kempy-call-iam-api-lambda"
  description      = "HTTP API - Test IAM Lambda"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.kempy-call-iam-api-lambda-role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.9"
  timeout          = "30"
}

resource "aws_cloudwatch_log_group" "kempy-call-iam-api-lambda-log" {
  provider          = aws.region
  name              = "/aws/lambda/kempy-call-iam-api-lambda"
  retention_in_days = 7
}

resource "aws_iam_role" "kempy-call-iam-api-lambda-role" {
  name               = "kempy-call-iam-api-lambda-role"
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
    name   = "kempy-call-iam-api-lambda-role-policy"
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
                  "ssm:GetParameter"
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

resource "aws_iam_role_policy_attachment" "kempy-call-iam-api-lambda-role-invoke-api" {
  role       = aws_iam_role.kempy-call-iam-api-lambda-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}
