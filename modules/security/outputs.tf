output "alb_security_group_id" {
    description = "ID od the Application Security Group"
    value = aws_security_group.alb.id
}

output "application_security_group_id" {
  description = "ID of the application security group"
  value = aws_security_group.application.id
}

output "database_security_group_id" {
    description = "ID od the database security group"
    value = aws_security_group.database.id
}