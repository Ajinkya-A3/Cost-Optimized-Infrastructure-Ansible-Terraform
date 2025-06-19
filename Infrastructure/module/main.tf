locals {
  source_dir = dirname(var.lambda_source_file)
  zip_output = "${local.source_dir}/${basename(replace(var.lambda_source_file, ".py", ".zip"))}"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = var.lambda_source_file
  output_path = local.zip_output
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "${var.lambda_function_name}-policy"
  description = "IAM policy for Lambda execution"
  policy      = templatefile(var.policy_template_path, {})
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_exec_policy.arn
}

resource "aws_lambda_function" "lambda" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda_handler
  runtime       = "python3.10"
  timeout       = 5
  filename      = data.archive_file.lambda_zip.output_path

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attach
  ]
}

resource "aws_cloudwatch_event_rule" "lambda_trigger" {
  name                = var.cloudwatch_rule_name
  description         = var.cloudwatch_rule_description
  schedule_expression = var.cloudwatch_schedule_expression
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_trigger.arn
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_trigger.name
  target_id = var.lambda_function_name
  arn       = aws_lambda_function.lambda.arn
}