<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
Creates an ECS cluster backed by an AutoScaling Group.

The cluster is minimally configured and expects any ECS service added will
use `awsvpc` networking and Task IAM Roles for access control.

Creates the following resources:

* IAM role for the container instance.
* Launch Configuration and AutoScaling group.
* ECS cluster.

## Usage

```hcl
data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

module "app_ecs_cluster" {
  source = "…/modules/aws-ecs-cluster"

  name        = "app"
  environment = "prod"

  image_id      = "${data.aws_ami.ecs_ami.image_id}"
  instance_type = "t2.micro"

  subnet_ids       = "${module.vpc.private_subnets}"
  desired_capacity = 3
  max_size         = 3
  min_size         = 3
}
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| desired_capacity | Desired instance count. | string | `2` | no |
| environment | Environment tag. | string | - | yes |
| image_id | Amazon ECS-Optimized AMI. | string | - | yes |
| instance_type | The instance type to use. | string | `t2.micro` | no |
| max_size | Maxmimum instance count. | string | `2` | no |
| min_size | Minimum instance count. | string | `2` | no |
| name | The ECS cluster name this will launching instances for. | string | - | yes |
| subnet_ids | A list of subnet IDs to launch resources in. | list | - | yes |
| use_AmazonEC2ContainerServiceforEC2Role_policy | Attaches the AWS managed AmazonEC2ContainerServiceforEC2Role policy to the ECS instance role. | string | `true` | no |
| vpc_id | The id of the VPC to launch resources in. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| ecs_cluster_arn | The ARN of the ECS cluster. |
| ecs_cluster_name | The name of the ECS cluster. |
| ecs_instance_role | The name of the ECS instance role. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
