

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20240306.2-arm64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_launch_configuration" "template" {
  image_id        = data.aws_ami.amazon_linux.id
  instance_type   = "t4g.nano"
  security_groups = [aws_security_group.ec2.id]
  user_data       = <<-EOL
  #!/bin/bash
  
  sudo apt-get update
  sudo apt-get -y install nginx mysql-client php7.4-fpm php-mysql 
  
  git clone https://github.com/Theo2lt/website-php.git
  cp website-php/default /etc/nginx/sites-available/
  cp website-php/employees_mng.php /var/www/html
  cp website-php/index.html /var/www/html
  mkdir /var/www/inc
  echo "<?php
    define('DB_SERVER', '${aws_db_instance.database.address}');
    define('DB_USERNAME', '${var.user}');
    define('DB_PASSWORD', '${var.pwd}');
    define('DB_DATABASE', '${var.db}');
    define('ID_INSTANCE', '$(curl http://169.254.169.254/latest/meta-data/instance-id)');
    define('AVAILABILITY_ZONE', '$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)');
  ?>" > /var/www/inc/dbinfo.inc
  sudo systemctl restart nginx
  EOL

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 10
    encrypted             = true
    delete_on_termination = true
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  name                 = "autoscaling_group"
  launch_configuration = aws_launch_configuration.template.name
  vpc_zone_identifier  = data.aws_subnets.private.ids
  desired_capacity     = 1
  min_size             = 1
  max_size             = 5

  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = "backend-php"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_utilisation_up" {
  name                   = "scale_policy_cpu_utilisation_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}

resource "aws_cloudwatch_metric_alarm" "watch_cpu_alarm_up" {
  alarm_name          = "watch_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 30
  statistic           = "Average"
  threshold           = 40

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.cpu_utilisation_up.arn]
}


resource "aws_autoscaling_policy" "cpu_utilisation_down" {
  name                   = "scale_policy_cpu_utilisation_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group.name
}


resource "aws_cloudwatch_metric_alarm" "watch_cpu_alarm_down" {
  alarm_name          = "watch_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 30
  statistic           = "Average"
  threshold           = 10

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling_group.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.cpu_utilisation_down.arn]
}
