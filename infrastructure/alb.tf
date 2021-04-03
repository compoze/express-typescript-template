resource "aws_lb" "alb" {
  name = local.name

  subnets         = data.terraform_remote_state.vpc.outputs.public_subnets
  security_groups = [aws_security_group.alb.id]

  tags = local.common_tags
}

resource "aws_lb_target_group" "target" {
  name                 = local.name
  port                 = "80"
  protocol             = "HTTP"
  vpc_id               = data.terraform_remote_state.vpc.outputs.vpc_id
  target_type          = "ip"
  deregistration_delay = "15"

  tags = local.common_tags

  health_check {
    path                = "/api"
    timeout             = "60"
    healthy_threshold   = "2"
    unhealthy_threshold = "4"
    interval            = "180"
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.target.id
    type             = "forward"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = data.terraform_remote_state.route-53.outputs.acm_certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.target.id
    type             = "forward"
  }
}

resource "aws_route53_record" "dnsname" {
  zone_id = data.terraform_remote_state.route-53.outputs.zone_id
  name    = local.dns_name
  type    = "A"

  alias {
    name                   = "dualstack.${aws_lb.alb.dns_name}"
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = false
  }
}

resource "aws_security_group" "alb" {
  name        = "${local.name}-alb-sg"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "${local.name} Load Balancer Security Group"

  ingress {
    description = "Allow inbound traffic to HTTP"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound traffic to HTTPS"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "Allow outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name, description]
  }

  tags = merge(
  local.common_tags,
  {
    "Name" = "${local.name}-alb-sg"
  },
  )
}
