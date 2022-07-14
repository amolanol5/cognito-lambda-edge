# role
resource "aws_iam_role" "iam_for_lambda" {
  name = "lambda_edge_assume_policy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": "exectionRole"
    }
  ]
}
EOF
}

# policy
resource "aws_iam_policy" "lambda_edge_policy" {
  name        = "lambda_edge_policy"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
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
      "Sid": "Stmt1657743377437",
      "Action": [
        "lambda:GetFunction",
        "lambda:GetFunction",
        "lambda:GetFunctionConfiguration"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:lambda:us-east-1:515411507312:function:lambda-edge-1"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "lambda_edge_policy_att" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_edge_policy.arn
}


resource "aws_lambda_permission" "with_edge" {
  statement_id  = "replicator-lambda-GetFunction"
  action        = "lambda:GetFunction"
  function_name = aws_lambda_function.edge_lambda.function_name
  principal     = "replicator.lambda.amazonaws.com"
  source_arn    = aws_lambda_function.edge_lambda.arn
}


resource "aws_lambda_function" "edge_lambda" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  filename      = "src/hello-world-python.zip"
  function_name = "lambda-edge-2"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.test"
  runtime = "python3.8"
  publish = true
  
  }