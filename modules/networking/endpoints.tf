
# Security Group compartido por los Interface VPC Endpoints.
# Limita el acceso HTTPS a recursos que se encuentran dentro de la VPC.

resource "aws_security_group" "vpc_endpoints" {
  name        = "aws-infrastructure-platform-dev-vpce-sg"
  description = "Allow HTTPS traffic from the VPC to interface endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "aws-infrastructure-platform-dev-vpce-sg"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Tier        = "networking"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-2.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]
  # Hace que el nombre regional de SSM resuelva a las IP privadas
  # del endpoint, evitando utilizar una ruta pública hacia AWS.
  private_dns_enabled = true

  tags = {
    Name        = "aws-infrastructure-platform-dev-ssm-endpoint"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Tier        = "networking"
  }
}

# provides the communication channels required by the session manager
# unlike the SSM api endpoint , this endpoint handles the session data
# exchanged between the SSM agent and the Systems Manager Service
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-2.ssmmessages"
  vpc_endpoint_type = "Interface"

  #deploy an endponit network interface in each privcate AZ
  # so instances in both subnets can establish private sessions
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  # reuse the existing endpoint secirity group
  # this avoids requiring public internet connectivity or NA
  # No necesitamos crear otro Security Group: ambos endpoints pueden compartir el mismo porque utilizan HTTPS por el puerto 443 y tienen el mismo requisito de acceso.
  private_dns_enabled = true

  tags = {
    name        = "aws-infrastructure-platform-dev-ssmmessages-endpoint"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Tier        = "Networking"
  }
}