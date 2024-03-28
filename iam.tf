##########################
#### ec2_default_role ####
##########################

resource "aws_iam_instance_profile" "ec2_default_profile" {
  name = "ec2_default_role"
  role = aws_iam_role.ec2_default_role.name
}

resource "aws_iam_role" "ec2_default_role" {
  name = "ec2_default_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2AssumeRole"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

##################################################################################
# Attach AWS and Customer managed policies to the IAM role 
##################################################################################

resource "aws_iam_policy_attachment" "ssm-attach" {
  name       = "managed-ssm-policy-attach"
  roles      = [aws_iam_role.ec2_default_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "cloudwatch-attach" {
  name       = "managed-cloudwatch-policy-attach"
  roles      = [aws_iam_role.ec2_default_role.id]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

