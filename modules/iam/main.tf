# Vamos a crear dos recursos:
# 1. aws_iam_role: define la identidad y los permisos que podrá asumir EC2.
# 2. aws_iam_instance_profile: permite asociar ese rol a una instancia EC2.



resource "aws_iam_role" "ec2" { # identidad que posteriormente tendrá permisos asociados.
  name = "${var.project_name}-${var.environment}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  }) #  data.aws_iam_policy_document.ec2_assume_role.json #  política de confianza, no una política que conceda acceso a S3, SSM u otros servicios.

  tags = var.tags
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {                     # conecta una política IAM con un rol.
  role       = aws_iam_role.ec2.name                                  # indica qué rol recibirá los permisos.
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" # identifica la política administrada por AWS.

  # AmazonSSMManagedInstanceCore permite que el agente SSM de la instancia se comunique con Systems Manager y registre la instancia como administrada.
}