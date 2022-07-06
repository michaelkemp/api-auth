resource "aws_iam_user" "iam-user" {
  name = "kempy-iam-user"
}

resource "aws_iam_access_key" "iam-user" {
  user = aws_iam_user.iam-user.name
}

resource "aws_iam_user_policy_attachment" "policy-attachment" {
  user       = aws_iam_user.iam-user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}

resource "aws_ssm_parameter" "id" {
  name     = "/kempy/user/id"
  type     = "SecureString"
  value    = aws_iam_access_key.iam-user.id
  provider = aws.region
}

resource "aws_ssm_parameter" "secret" {
  name     = "/kempy/user/secret"
  type     = "SecureString"
  value    = aws_iam_access_key.iam-user.secret
  provider = aws.region
}

