### elb ###
resource "aws_lb" "hra_load_balancer" {
  name               = "web-app-lb"
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.hra_elb.id]
}

### target group hra ###
resource "aws_lb_target_group" "hra_lb_target_group" {
  name     = "hra-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_hra.id

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
resource "aws_lb_listener" "hra_lb_listener" {
  load_balancer_arn = aws_lb.hra_load_balancer.arn
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


resource "aws_autoscaling_attachment" "hra_attachement_targets" {
  autoscaling_group_name = aws_autoscaling_group.hra_asg.id
  lb_target_group_arn    = aws_lb_target_group.hra_lb_target_group.arn
}


resource "aws_lb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.hra_lb_listener.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.hra_lb_target_group.arn
  }
}