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
  source = "trussworks/ecs-cluster/aws"

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

## Terraform Versions

Terraform 0.12. Pin module version to ~> 2.0. Submit pull-requests to master branch.

Terraform 0.11. Pin module version to ~> 1.0. Submit pull-requests to terraform011 branch.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| desired\_capacity | Desired instance count. | string | `"2"` | no |
| environment | Environment tag. | string | n/a | yes |
| image\_id | Amazon ECS-Optimized AMI. | string | n/a | yes |
| instance\_type | The instance type to use. | string | `"t2.micro"` | no |
| max\_size | Maxmimum instance count. | string | `"2"` | no |
| min\_size | Minimum instance count. | string | `"2"` | no |
| name | The ECS cluster name this will launching instances for. | string | n/a | yes |
| subnet\_ids | A list of subnet IDs to launch resources in. | list(string) | n/a | yes |
| use\_AmazonEC2ContainerServiceforEC2Role\_policy | Attaches the AWS managed AmazonEC2ContainerServiceforEC2Role policy to the ECS instance role. | string | `"true"` | no |
| vpc\_id | The id of the VPC to launch resources in. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ecs\_cluster\_arn | The ARN of the ECS cluster. |
| ecs\_cluster\_name | The name of the ECS cluster. |
| ecs\_instance\_role | The name of the ECS instance role. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Developer Setup

Install dependencies (macOS)

```shell
brew install pre-commit go terraform terraform-docs
```

### Testing

[Terratest](https://github.com/gruntwork-io/terratest) is being used for
automated testing with this module. Tests in the `test` folder can be run
locally by running the following command:

```text
make test
```

Or with aws-vault:

```text
AWS_VAULT_KEYCHAIN_NAME=<NAME> aws-vault exec <PROFILE> -- make test
```
