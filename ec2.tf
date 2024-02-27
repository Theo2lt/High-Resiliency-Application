/*
#Terraform to launch EC2 Instance #

resource "aws_launch_configuration" "hra_template_conf" {
  name_prefix   = "hra-ec2-"
  image_id      = "ami-08031206a0ff5a6ac"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.hra_ec2.id]
  key_name        = "hra"

  user_data = <<-EOL
  #!/bin/bash
  
  sudo apt-get update
  sudo apt-get -y install nginx mysql-client php7.4-fpm php-mysql
  
  git clone https://github.com/Theo2lt/website-php.git
  cp website-php/default /etc/nginx/sites-available/
  cp website-php/employees_mng.php /var/www/html
  cp website-php/index.html /var/www/html
  mkdir /var/www/inc
  echo "<?php
    define('DB_SERVER', '${aws_db_instance.db_hra.address}');
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
}


resource "aws_autoscaling_group" "hra_asg" {
  name                 = "hra_asg"
  launch_configuration = aws_launch_configuration.hra_template_conf.name
  vpc_zone_identifier  = aws_subnet.private.*.id
  desired_capacity     = 1
  min_size             = 1
  max_size             = 5

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "cpu_utilisation_up" {
  name = "scale_policy_cpu_utilisation_up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 60
  autoscaling_group_name = aws_autoscaling_group.hra_asg.name
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
    AutoScalingGroupName = aws_autoscaling_group.hra_asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.cpu_utilisation_up.arn]
}


resource "aws_autoscaling_policy" "cpu_utilisation_down" {
  name = "scale_policy_cpu_utilisation_down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 60
  autoscaling_group_name = aws_autoscaling_group.hra_asg.name
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
    AutoScalingGroupName = aws_autoscaling_group.hra_asg.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.cpu_utilisation_down.arn]
}

*/