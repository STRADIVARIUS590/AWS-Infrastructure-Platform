resource "aws_lb" "main" {
    name = "aip-dev-alb"
    internal = false # el ALB será accesible desde Internet.
    load_balancer_type = "application" # 	Utiliza HTTP/HTTPS y puede enrutar según reglas de capa 7.

    security_groups = [ var.alb_security_group_id ] # asociamos grupos de seguridad

    subnets = [ # desplegamos el ALB en las dos zonas de disponibilidad.
        var.public_subnet_a_id,
        var.public_subnet_b_id,
    ]

    tags = {
        Name =    "aip-dev-alb"
        Environment = "dev"
        ManagedBy   = "Terraform"
    }
}
