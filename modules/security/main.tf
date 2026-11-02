# seciruty group for the application load balancer
resource "aws_security_group" "alb" {
  name        = "aws-infrastructure-platform-dev-alb-sg"
  description = "Allow HTTP and HTTPS traffic from the internet"
  vpc_id      = var.vpc_id

  tags = {
    Name = "aws-infrastructure-platform-dev-alb-sg"
  }
}

# allow incoming HTTP traffic from the internet
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  description = "Allow HTTP from the internet"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80

  cidr_ipv4 = "0.0.0.0/0"
}

# Parámetro	Significado
# security_group_id	Firewall al que pertenece la regla
# ip_protocol	Protocolo TCP
# from_port	Puerto inicial
# to_port	Puerto final
# cidr_ipv4	Rango IPv4 autorizado
# 
# ¿Por qué 0.0.0.0/0?
# 
# Significa cualquier dirección IPv4. Es razonable para un ALB público que debe recibir solicitudes desde Internet.
# 
# Importante: esto no expone directamente tus servidores ni bases de datos. Solamente autoriza HTTP y HTTPS en el Security Group del ALB.
# 
# Todavía no vamos a desplegar nada. Cuando termines, revisaremos las reglas de salida (Egress).

# allow HTTPS traffic from the internet
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id

  description = "Allow HTTPS from the internet"

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443

  cidr_ipv4 = "0.0.0.0/0"
}

# Allow the ALB to reach application targets only.
resource "aws_vpc_security_group_egress_rule" "alb_to_application" {
  security_group_id = aws_security_group.alb.id

  description                  = "Allow ALB traffic to application instances"
  ip_protocol                  = "tcp"
  from_port                    = var.application_port
  to_port                      = var.application_port
  referenced_security_group_id = aws_security_group.application.id
}

# security group for backend application instances
resource "aws_security_group" "application" {
  name        = "aws-infrastructure-platform-dev-application-sg"
  description = "Allow traffic from the Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "aws-infrastructure-platform-dev-application-sg"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
# Internet
#    |
#    | TCP 80 / 443
#    v
# [ ALB Security Group ]
#    |
#    | TCP 8080
#    v
# [ Application Security Group ]
# 
# allip application traffic exclusively from the ALB


# ¿Por qué permitimos toda la salida?
# 
# Porque las aplicaciones pueden necesitar comunicarse con:
# - Bases de datos.
# - APIs externas.
# - Servicios AWS.
# - Repositorios de paquetes y actualizaciones
resource "aws_vpc_security_group_ingress_rule" "application_from_alb" {
  security_group_id = aws_security_group.application.id # a que firewall pertenece la regla

  description                  = "Allow traffic from the ALB"
  ip_protocol                  = "tcp"
  from_port                    = var.application_port
  to_port                      = var.application_port
  referenced_security_group_id = aws_security_group.alb.id # Indica qué origen está autorizado para conectarse.
}

resource "aws_vpc_security_group_egress_rule" "application_all_outbound" {

  security_group_id = aws_security_group.application.id

  description = "Allow outbound traffic"
  ip_protocol = "-1"

  cidr_ipv4 = "0.0.0.0/0"
}

# Cliente → Aplicación	Cliente → ALB → Aplicación
# Aplicación → Cliente (respuesta)	Aplicación → ALB → Cliente
# Aplicación → API externa	Aplicación → NAT → Internet
# Aplicación → Base de datos	Aplicación → Base de datos




# security group for database instances

# Nuestra arquitectura ya tiene tres niveles de seguridad:
# 1. ALB: recibe tráfico público.
# 2. Application: recibe tráfico del ALB.
# 3. Database: recibirá tráfico de las aplicaciones.
resource "aws_security_group" "database" {
  name        = "aws-infrastructure-platform-dev-database-sg"
  description = "Allow database traffic only from the application instances"
  vpc_id      = var.vpc_id


  # Remove AWS's default allow-all outbound rule.
  # Response traffic remains automatically permitted.
  egress = []

  tags = {
    Name        = "aws-infrastructure-platform-dev-database-sg"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# allow database connections exclusively from applications instances
# security_group_id: el firewall de destino es Database.
# from_port / to_port: permite el puerto PostgreSQL 5432.
# referenced_security_group_id: solamente permite conexiones procedentes de recursos asociados al Application Security Group.
resource "aws_vpc_security_group_ingress_rule" "database_from_application" {
  security_group_id = aws_security_group.database.id

  description                  = "Allow database traffic from application instances"
  ip_protocol                  = "tcp"
  from_port                    = var.database_port
  to_port                      = var.database_port
  referenced_security_group_id = aws_security_group.application.id
}