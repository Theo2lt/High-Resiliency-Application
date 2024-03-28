

### elb ###
resource "aws_lb" "application_load_balancer" {
  name               = "ApplicationLoadBalancer"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.public.ids
  security_groups    = [aws_security_group.application_load_balancer.id]
}

### target group hra ###
resource "aws_lb_target_group" "targets" {
  name     = "targets"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.network.aws_vpc_vpc.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    port                = "traffic-port"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

### listener https ###
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {

    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}


resource "aws_autoscaling_attachment" "attachement_ec2" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.id
  lb_target_group_arn    = aws_lb_target_group.targets.arn
}


resource "aws_lb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targets.arn
  }
}

