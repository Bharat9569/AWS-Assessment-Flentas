provider "aws" {
  region = "us-east-1"
}

variable "prefix" { type=string; default="FirstName_Lastname" }


resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name                = "${var.prefix}_billing_alarm_100INR"
  alarm_description         = "Alert when estimated charges exceed 100 INR (approx)"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "EstimatedCharges"
  namespace                 = "AWS/Billing"
  statistic                 = "Maximum"
  threshold                 = 2    # NOTE: Set threshold value to appropriate amount in USD. AWS reports billing in USD by default.
  dimensions = {
    Currency = "USD"
  }
  alarm_actions = [] # Add SNS topic ARN here if you want notifications
  period = 21600
}


resource "aws_budgets_budget" "free_tier_alert" {
  name = "${var.prefix}_free_tier_alert"
  budget_type = "USAGE"
  time_unit = "MONTHLY"

  limit_amount = "15" 
  limit_unit = "GB"   

  
  cost_filters = {}
  cost_types {
    include_credit = true
    include_other_subscription = true
  }
}