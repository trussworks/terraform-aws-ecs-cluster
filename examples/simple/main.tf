data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

resource "aws_security_group" "test_group" {
  name        = var.test_name
  description = "creates a security group to test with"
  vpc_id      = module.vpc.vpc_id
}


module "app_ecs_cluster" {
  source = "../../"

  name        = var.test_name
  environment = "test"

  image_id      = data.aws_ami.ecs_ami.image_id
  instance_type = "t2.micro"

  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [aws_security_group.test_group.id]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.53.0"

  name            = var.test_name
  cidr            = "10.0.0.0/16"
  azs             = var.vpc_azs
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  public_subnets  = ["10.0.104.0/24", "10.0.105.0/24", "10.0.106.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}
