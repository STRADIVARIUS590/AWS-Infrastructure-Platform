
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.3.0"
    }

    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}
# source define cómo Packer obtiene la máquina temporal que utilizará para construir nuestra imagen.
# amazon-ebs: tipo de builder. Es el builder que utiliza una instancia EC2 respaldada por EBS para construir una AMI.
# El proceso simplificado es:
# 1. Packer lanza una instancia EC2 temporal.
# 2. Se conecta por SSH.
# 3. Ejecuta las configuraciones que definamos.
# 4. Crea una AMI a partir de esa instancia.
# 5. Limpia los recursos temporales.

source "amazon-ebs" "al2023" {
  region        = "us-east-2"
  instance_type = "t3.micro" # define el tamaño de esa instancia temporal.

  source_ami_filter { # le indicamos al packer qye imagen base va a utilzar
    filters = {
      name                = "al2023-ami-2023.*-kernel-6.1-x86_64" # 	Busca imágenes cuyo nombre coincida con el patrón.
      root-device-type    = "ebs"                                 # Exige que utilicen EBS como dispositivo raíz.
      virtualization-type = "hvm"                                 #	Busca imágenes HVM
      state               = "available"                           # 	Solo acepta imágenes disponibles.
    }

    owners      = ["137112412989"] # Limita la búsqueda al propietario oficial de Amazon.
    most_recent = true             # 	Selecciona la más reciente que cumpla los filtros.
  }

  vpc_id    = "vpc-0b756a0d2c1c7401a"    # Indica en qué VPC se creará la instancia temporal.
  subnet_id = "subnet-0430ce2b3147cf302" # Indica en qué subnet se lanzará.

  associate_public_ip_address = true # Solicita una IP pública para que Packer pueda establecer la conexión SSH.

  temporary_security_group_source_cidrs = [ # Packer crea un Security Group temporal y restringe el acceso SSH a las direcciones indicadas.
    "138.186.31.156/32"
  ]

  ssh_username = "ec2-user" # usuario del sistema operativo Amazon Linux.
  ssh_timeout  = "10m"      # tiempo máximo de espera para establecer la conexión.

  ami_name        = "aip-dev-al2023-{{timestamp}}"
  ami_description = "AWS Infrastructure Platform - Amazon Linux 2023"

  tags = {
    Name        = "aip-dev-al2023"
    Project     = "aws-infrastructure-platform"
    Environment = "dev"
    ManagedBy   = "Packer"
  }
}

build {
  sources = [
    "source.amazon-ebs.al2023"
  ]

  provisioner "ansible" {
    playbook_file = "../../ansible/playbooks/base.yml"

    ansible_env_vars = [
      "ANSIBLE_CONFIG=/home/dell/.ansible.cfg"
    ]
  }

  post-processor "manifest" { # exportamos el manifest para tener variables como el ami id fuera del contesxto del packer
    output = "manifest.json"
    strip_path = true
  }
}

