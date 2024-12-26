terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.78.0"
    }
  }
}

#Configure AWS credentials
provider "aws" {
  # Configuration options
  region = "sa-east-1"
  access_key = ""
  secret_key = ""
}

resource "aws_iam_role" "lambda_role" {
    name = "terraform_aws_lambda_role"
    assume_role_policy = jsonencode(
    {
        "Version": "2012-10-17"
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal":{
                    "Service" : "lambda.amazonaws.com"
                },
                "Effect": "Allow"
                "Sid": ""
            }
        ]
    })
}

#IAM policy for logging from a lambda
resource "aws_iam_policy" "iam_policy_for_lambda" {
  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = jsonencode(
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
  })
}

# policy Attachment on the role
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role        = aws_iam_role.lambda_role.name
  policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

#generates an archive from content, a file, or a directory of files
data "archive_file" "zip_the_python_code" {
  type = "zip"
  source_dir = "${path.module}/python/"
  output_path = "${path.module}/python/hello-python.zip"
}

#Create Lambda function
# In terraform ${path.module} is the current directory
resource "aws_lambda_function" "terraform_aws_lambda_func" {
  filename = "${path.module}/python/hello-python.zip"
  function_name = "group01-jpomm-Lambda-Function"
  role = aws_iam_role.lambda_role.arn
  handler = "hello-python.lambda_handler"
  runtime = "python3.8"
  depends_on = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}

output "terraform_aws_role_output" {
  value = aws_iam_role.lambda_role.name
}

# DynamoDB Table
resource "aws_dynamodb_table" "grupo01_jpomm" {
  name           = "grupo01-jpomm-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = "dev"
  }
}




