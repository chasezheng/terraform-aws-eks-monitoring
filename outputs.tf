output "namespace" {
  value       = module.resources.namespace
  description = "The name (`metadata.name`) of the namespace"
}

output "svc" {
  value = module.resources.svc
}