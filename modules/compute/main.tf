resource "aws_instance" "application" {
  count         = length(var.subnet_ids) # Terraform crea tantas instancias como subnets recibamos. Si recibimos dos subnets, crea dos EC2
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id              = var.subnet_ids[count.index] # subnet_id = var.subnet_ids[count.index]
  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile = var.instance_profile_name

  associate_public_ip_address = false # Las instancias no tendrán IP pública. El tráfico de entrada llegará a través del ALB.

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-app-${count.index + 1}"
  })
}

resource "aws_lb_target_group_attachment" "application" {
  count = length(aws_instance.application)

  target_group_arn = var.target_group_arn
  target_id        = aws_instance.application[count.index].id
  port             = 8080
}



