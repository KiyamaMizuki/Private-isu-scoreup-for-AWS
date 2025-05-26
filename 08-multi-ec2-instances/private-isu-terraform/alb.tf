data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "tf_elb_service_account" {}

resource "aws_lb" "private_isu_alb" {
  name               = "Private-isu-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_1a.id, aws_subnet.public_1c.id]

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.id
    prefix  = "private-isu"
    enabled = true
  }
}

resource "aws_lb_target_group" "private_isu" {
  name     = "Private-isu"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb_target_group_attachment" "private_isu" {
  target_group_arn = aws_lb_target_group.private_isu.arn
  target_id        = aws_instance.private_isu_web.id
}

resource "aws_lb_target_group_attachment" "private_isu02" {
  target_group_arn = aws_lb_target_group.private_isu.arn
  target_id        = aws_instance.private_isu_web02.id
}

resource "aws_lb_listener" "private_isu" {
  load_balancer_arn = aws_lb.private_isu_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "503"
    }
  }
}

resource "aws_lb_listener_rule" "private_isu" {
  listener_arn = aws_lb_listener.private_isu.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private_isu.arn
  }

  condition {
    http_header {
      http_header_name = "X-Custom-Header"
      values           = [local.custom_header_value]
    }
  }
}

resource "aws_s3_bucket" "lb_logs" {
  bucket = "private-isu-alb-logs-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_policy" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id

  policy = data.aws_iam_policy_document.lb_logs_policy.json
}

data "aws_iam_policy_document" "lb_logs_policy" {
  statement {
    actions = ["s3:PutObject"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.tf_elb_service_account.arn]
    }

    resources = [
      "${aws_s3_bucket.lb_logs.arn}/*",
    ]
  }
}
