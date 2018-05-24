/**
 * Creates an ECS cluster backed by an AutoScaling Group.
 *
 * The cluster is minimally configured and expects any ECS service added will
 * use `awsvpc` networking and Task IAM Roles for access control.
 *
 * Creates the following resources:
 *
 * * IAM role for the container instance.
 * * Launch Configuration and AutoScaling group.
 * * ECS cluster.
 *
 * ## Usage
 *
 * ```hcl
 * data "aws_ami" "ecs_ami" {
 *   most_recent = true
 *   owners      = ["amazon"]
 *
 *   filter {
 *     name   = "name"
 *     values = ["amzn-ami-*-amazon-ecs-optimized"]
 *   }
 * }
 *
 * module "app_ecs_cluster" {
 *   source = "…/modules/aws-ecs-cluster"
 *
 *   name        = "app"
 *   environment = "prod"
 *
 *   image_id      = "${data.aws_ami.ecs_ami.image_id}"
 *   instance_type = "t2.micro"
 *
 *   subnet_ids       = "${module.vpc.private_subnets}"
 *   desired_capacity = 3
 *   max_size         = 3
 *   min_size         = 3
 * }
 * ```
 */

locals {
  cluster_name = "${var.name}-${var.environment}"
}

#
# ECS
#

resource "aws_ecs_cluster" "main" {
  name = "${local.cluster_name}"

  lifecycle {
    create_before_destroy = true
  }
}

#
# IAM
#

# Docs
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html

data "aws_iam_policy_document" "ecs_instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecs-instance-role-${local.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_instance_assume_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = "${aws_iam_role.ecs_instance_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceRole-${local.cluster_name}"
  path = "/"
  role = "${aws_iam_role.ecs_instance_role.name}"
}

#
# Security Group
#

resource "aws_security_group" "main" {
  name        = "asg-${local.cluster_name}"
  description = "${local.cluster_name} ASG security group"
  vpc_id      = "${var.vpc_id}"

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "main" {
  description       = "All outbound"
  security_group_id = "${aws_security_group.main.id}"

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

#
# EC2
#

resource "aws_launch_configuration" "main" {
  name_prefix = "${format("ecs-%s-", local.cluster_name)}"

  iam_instance_profile = "${aws_iam_instance_profile.ecs_instance_profile.name}"

  instance_type               = "${var.instance_type}"
  image_id                    = "${var.image_id}"
  associate_public_ip_address = false
  security_groups             = ["${aws_security_group.main.id}"]

  root_block_device {
    volume_type = "standard"
  }

  ebs_block_device {
    device_name = "/dev/xvdcz"
    volume_type = "standard"
    encrypted   = true
  }

  user_data = <<EOF
#!/bin/bash
# The cluster this agent should check into.
echo 'ECS_CLUSTER=${aws_ecs_cluster.main.name}' >> /etc/ecs/ecs.config

# Disable privileged containers.
echo 'ECS_DISABLE_PRIVILEGED=true' >> /etc/ecs/ecs.config
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "main" {
  name = "ecs-${local.cluster_name}"

  launch_configuration = "${aws_launch_configuration.main.id}"
  termination_policies = ["OldestLaunchConfiguration", "Default"]
  vpc_zone_identifier  = ["${var.subnet_ids}"]

  desired_capacity = "${var.desired_capacity}"
  max_size         = "${var.max_size}"
  min_size         = "${var.min_size}"

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "ecs-${local.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Cluster"
    value               = "${local.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }
}
