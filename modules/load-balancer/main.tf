resource "aws_lb" "main" {
  name               = "aip-dev-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [var.alb_security_group_id]

  subnets = [
    var.public_subnet_a_id,
    var.public_subnet_b_id,
  ]

  tags = {
    Name        = "aip-dev-alb"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb_target_group" "application" {
  name        = "aip-dev-app-tg"
  port        = var.application_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "aip-dev-app-tg"
  }
}

# El Listener determina qué hacer cuando el ALB recibe una solicitud.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application.arn
  }

}