output "ecs_instance_role" {
  description = "The ECS Instanc Role."
  value       = module.app_ecs_cluster.ecs_instance_role
}

output "ecs_cluster_name" {
  description = "The ECS Cluster Name."
  value       = module.app_ecs_cluster.ecs_cluster_name
}

output "ecs_cluster_arn" {
  description = "The ECS Cluster ARN."
  value       = module.app_ecs_cluster.ecs_cluster_arn
}
