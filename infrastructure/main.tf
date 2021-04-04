terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "test-org-compoze"
  }
}

resource "aws_cloudwatch_log_group" "task" {
  name              = "/aws/ecs/${local.name}"
  retention_in_days = 180
  tags              = local.common_tags
}

resource "aws_ecr_repository" "repo" {
  name                 = "${var.environment}/${var.name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.common_tags
}

resource "aws_ecs_cluster" "cluster" {
  name = local.name

  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT",
  ]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  tags = local.common_tags
}

resource "aws_ecs_service" "svc" {
  name                               = var.name
  task_definition                    = aws_ecs_task_definition.task.family
  cluster                            = aws_ecs_cluster.cluster.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 0
  desired_count                      = 1
  enable_ecs_managed_tags            = true
  health_check_grace_period_seconds  = 240
  launch_type                        = "FARGATE"
  propagate_tags                     = "SERVICE"

  network_configuration {
    security_groups = [
      aws_security_group.ecs.id,
    data.terraform_remote_state.vpc.outputs.ecr_security_group_id]
    subnets          = local.private_subnets_id
    assign_public_ip = false
  }


  load_balancer {
    container_name   = var.name
    container_port   = 8080
    target_group_arn = aws_lb_target_group.target.arn
  }

  lifecycle {
    ignore_changes = [
    desired_count]
  }

  tags = local.common_tags
}

resource "aws_ecs_task_definition" "task" {
  family             = local.name
  execution_role_arn = aws_iam_role.task.arn
  task_role_arn      = aws_iam_role.task.arn
  network_mode       = "awsvpc"
  cpu                = 256
  memory             = 512

  requires_compatibilities = [
  "FARGATE"]

  container_definitions = jsonencode([
    {
      name              = var.name
      image             = "${aws_ecr_repository.repo.repository_url}:latest"
      memoryReservation = 512
      environment = [
        {
          name  = "NODE_ENV"
          value = var.environment
        },
        {
          name : "PORT",
          value : "8080"
        },
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.task.name,
          awslogs-region        = var.region
          awslogs-stream-prefix = local.name
        }
      },
      portMappings : [
        {
          containerPort : 8080
        }
      ]
    }
  ])

  tags = local.common_tags
}

resource "aws_iam_role" "task" {
  name               = "${local.name}-task"
  assume_role_policy = data.aws_iam_policy_document.task.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "task" {
  statement {
    actions = [
    "sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
      "ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "exec" {
  role       = aws_iam_role.task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

//resource "aws_appautoscaling_target" "this" {
//  min_capacity = 0
//  max_capacity = 1
//  resource_id = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.svc.name}"
//  //  role_arn           = data.aws_iam_role.ecs-auto-scaling.arn # removed based on github issue: https://github.com/azavea/terraform-aws-ecs-cluster/issues/24
//  scalable_dimension = "ecs:service:DesiredCount"
//  service_namespace = "ecs"
//
//  lifecycle {
//    ignore_changes = [
//      resource_id]
//  }
//}
//
//resource "aws_appautoscaling_policy" "out" {
//  name = "add_${var.name}_workers_when_jobs_are_high"
//  policy_type = "StepScaling"
//  resource_id = aws_appautoscaling_target.this.resource_id
//  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
//  service_namespace = aws_appautoscaling_target.this.service_namespace
//
//  step_scaling_policy_configuration {
//    adjustment_type = "ChangeInCapacity"
//    cooldown = 60
//    metric_aggregation_type = "Average"
//    min_adjustment_magnitude = 0
//
//    step_adjustment {
//      metric_interval_lower_bound = "0"
//      scaling_adjustment = 1
//    }
//  }
//}
//
//resource "aws_appautoscaling_policy" "in" {
//  name = "remove_${var.name}_workers_when_jobs_are_low"
//  policy_type = "StepScaling"
//  resource_id = aws_appautoscaling_target.this.resource_id
//  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
//  service_namespace = aws_appautoscaling_target.this.service_namespace
//
//  step_scaling_policy_configuration {
//    adjustment_type = "ChangeInCapacity"
//    cooldown = 60
//    metric_aggregation_type = "Average"
//    min_adjustment_magnitude = 0
//
//    step_adjustment {
//      metric_interval_upper_bound = -1
//      scaling_adjustment = -1
//    }
//  }
//}

//resource "aws_cloudwatch_metric_alarm" "out" {
//  alarm_name        = "${var.environment}_${var.name}_growing"
//  alarm_description = "${var.environment} ${var.name} is growing"
//
//  comparison_operator = "GreaterThanThreshold"
//  metric_name         = "ApproximateNumberOfMessagesVisible"
//  namespace           = "AWS/SQS"
//  statistic           = "Sum"
//  threshold           = 0
//  datapoints_to_alarm = 1
//  evaluation_periods  = 1
//  period              = 60
//  treat_missing_data  = "missing"
//
//  dimensions = {
//    "QueueName" = aws_sqs_queue.sqs.name
//  }
//
//  alarm_actions = [aws_appautoscaling_policy.out.arn]
//
//  tags = local.common_tags
//}
//
//resource "aws_cloudwatch_metric_alarm" "in" {
//  alarm_name        = "${var.environment}_${var.name}_shrinking"
//  alarm_description = "${var.environment} ${var.name} is shrinking"
//
//  comparison_operator = "LessThanThreshold"
//  metric_name         = "ApproximateNumberOfMessagesNotVisible"
//  namespace           = "AWS/SQS"
//  statistic           = "Sum"
//  threshold           = 1
//  datapoints_to_alarm = 9
//  evaluation_periods  = 9
//  period              = 60 * 4
//  treat_missing_data  = "missing"
//
//  dimensions = {
//    QueueName = aws_sqs_queue.sqs.name
//  }
//
//  alarm_actions = [aws_appautoscaling_policy.in.arn]
//  tags = local.common_tags
//}

resource "aws_security_group" "ecs" {
  name        = "${local.name}-ecs-sg"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "${local.name} ECS Security Group"

  ingress {
    description = "Allow inbound traffic from this security group"
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "Allow inbound traffic from this vpc"
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = [
    data.aws_vpc.selected.cidr_block]
  }

  ingress {
    description = "Allow inbound traffic from alb security group"
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    security_groups = [
    aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
    ipv6_cidr_blocks = [
    "::/0"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      name,
    description]
  }

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name}-ecs-sg"
    },
  )
}

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.repo.name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 10 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

##
# AWS ACM Certificate Definition
#
##


resource "aws_acm_certificate" "compoze_acm" {
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = [local.dns_name]
  tags = {
    Environment = "prod"
  }

  lifecycle {
    create_before_destroy = true
  }
}

##
# Route53 resources to perform DNS auto validation
#
##
resource "aws_route53_record" "cert_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.compoze_acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.terraform_remote_state.route-53.outputs.zone_id
}

resource "aws_acm_certificate_validation" "validation" {
  timeouts {
    create = "10m"
  }
  certificate_arn         = aws_acm_certificate.compoze_acm.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
}

