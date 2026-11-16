# Expone el ARN del Target Group para que otros módulos,
# como Compute, puedan registrar instancias sin acoplarse
# a la implementación interna del Load Balancer.
output "target_group_arn" {
  description = "ARN of the application target group"
  value       = aws_lb_target_group.application.arn
}
