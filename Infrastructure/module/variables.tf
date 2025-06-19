variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "lambda_handler" {
  description = "Handler method in Lambda"
  type        = string
  
}

variable "lambda_source_file" {
  description = "Path to the Lambda source .py file"
  type        = string
}

variable "policy_template_path" {
  description = "Path to IAM policy template file"
  type        = string
}

variable "cloudwatch_schedule_expression" {
  description = "Schedule expression for CloudWatch"
  type        = string
  default     = "rate(1 minute)"
}

variable "cloudwatch_rule_name" {
  description = "Name of the CloudWatch rule"
  type        = string
  default     = "every_minute"
}

variable "cloudwatch_rule_description" {
  description = "Description of the CloudWatch rule"
  type        = string
  default     = "Trigger Lambda every 1 minute"
}