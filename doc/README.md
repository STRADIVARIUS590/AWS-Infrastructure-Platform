# Documentación técnica de infraestructura AWS

## Alcance

Este documento describe la configuración Terraform del entorno `dev` y el módulo de red que este instancia. La infraestructura definida actualmente es una base de red; no declara balanceadores de carga, instancias, servicios de aplicación, bases de datos, grupos de seguridad, NAT Gateways ni endpoints.

## Componentes de Terraform

El entorno raíz configura el proveedor y sus datos de contexto, y llama al módulo `networking`. El módulo usa `vpc_cidr` para crear la red y expone outputs que el entorno raíz vuelve a publicar.

```mermaid
flowchart LR
    subgraph Root["Entorno raíz: environments/dev"]
        Vars["variables.tf<br/>región, perfil, entorno,<br/>proyecto y vpc_cidr"]
        Provider["providers.tf<br/>proveedor AWS y default_tags"]
        Locals["locals.tf<br/>common_tags y name_prefix"]
        Data["data.tf<br/>identidad, región y AZ disponibles"]
        Main["main.tf<br/>module networking"]
        RootOutputs["outputs.tf<br/>outputs del entorno"]

        Vars -->|"configura"| Provider
        Vars -->|"valores del entorno"| Locals
        Locals -->|"common_tags"| Provider
        Data -->|"valores consultados"| RootOutputs
        Locals -->|"common_tags"| RootOutputs
        Main -->|"outputs del módulo"| RootOutputs
    end

    subgraph Child["Módulo reutilizable: modules/networking"]
        ModuleInstance["Instancia module.networking"]
        ModuleVars["variables.tf<br/>vpc_cidr y validación CIDR"]
        Network["main.tf<br/>VPC, Internet Gateway,<br/>tablas pública, privada<br/>y de base de datos"]
        Subnets["subnets.tf<br/>6 subredes; asociaciones<br/>públicas y privadas"]
        ModuleOutputs["outputs.tf<br/>ID, CIDR y tabla principal"]

        ModuleInstance -->|"entrada del módulo"| ModuleVars
        ModuleVars -->|"CIDR"| Network
        ModuleVars -->|"CIDR para cidrsubnet"| Subnets
        Network -->|"VPC y dependencias"| Subnets
        Network -->|"atributos de VPC"| ModuleOutputs
    end

    Main -->|"source: ../../modules/networking"| ModuleInstance
    Main -->|"vpc_cidr = var.vpc_cidr"| ModuleVars
    Provider -.->|"configuración AWS heredada"| ModuleInstance
    ModuleOutputs -->|"vpc_id, vpc_cidr_block,<br/>main_route_table_id"| RootOutputs
```

## Arquitectura AWS

```mermaid
flowchart TB
    Dev["Entorno Terraform: environments/dev"]
    Module["Módulo networking"]
    VPC["VPC principal<br/>10.0.0.0/16"]
    IGW["Internet Gateway"]
    MainRT["Tabla principal de rutas<br/>creada automáticamente por AWS"]
    PublicRT["Tabla de rutas públicas"]
    PrivateRT["Tabla de rutas privadas<br/>sin rutas declaradas"]
    DatabaseRT["Tabla de rutas de base de datos<br/>sin rutas ni asociaciones"]
    DefaultRoute["Ruta 0.0.0.0/0"]

    subgraph AZA["us-east-2a"]
        PubA["Subred pública A<br/>10.0.1.0/24"]
        PrivA["Subred privada A<br/>10.0.11.0/24"]
        DBA["Subred de base de datos A<br/>10.0.21.0/24"]
    end

    subgraph AZB["us-east-2b"]
        PubB["Subred pública B<br/>10.0.2.0/24"]
        PrivB["Subred privada B<br/>10.0.12.0/24"]
        DBB["Subred de base de datos B<br/>10.0.22.0/24"]
    end

    Dev -->|"instancia"| Module
    Module -->|"crea"| VPC
    VPC ---|"contiene"| PubA
    VPC ---|"contiene"| PubB
    VPC ---|"contiene"| PrivA
    VPC ---|"contiene"| PrivB
    VPC ---|"contiene"| DBA
    VPC ---|"contiene"| DBB
    VPC -->|"adjunto"| IGW
    VPC -->|"crea por defecto"| MainRT
    VPC -->|"asociada a la VPC"| PublicRT
    VPC -->|"asociada a la VPC"| PrivateRT
    VPC -->|"asociada a la VPC"| DatabaseRT
    MainRT -.->|"asociación predeterminada"| DBA
    MainRT -.->|"asociación predeterminada"| DBB
    PublicRT -->|"incluye"| DefaultRoute
    DefaultRoute -->|"destino"| IGW
    PublicRT -.->|"asociación public_a"| PubA
    PublicRT -.->|"asociación public_b"| PubB
    PrivateRT -.->|"asociación private_a"| PrivA
    PrivateRT -.->|"asociación private_b"| PrivB
```

Ambas asociaciones públicas están declaradas en `subnets.tf` y utilizan los IDs de las subredes correspondientes. La tabla pública envía la ruta predeterminada al Internet Gateway.

## Recursos y relaciones

| Recurso | Configuración | Relación y función |
|---|---|---|
| VPC `aws_vpc.main` | `10.0.0.0/16`; compatibilidad DNS y nombres DNS habilitados | Contenedor de las seis subredes; es la VPC a la que se adjunta el Internet Gateway y a la que pertenece la tabla pública. |
| Internet Gateway `aws_internet_gateway.main` | Asociado a la VPC principal | Proporciona el destino para tráfico IPv4 hacia Internet cuando una tabla de rutas asociada tiene una ruta a este gateway. |
| Tabla principal de rutas | Creada automáticamente al crear la VPC; su ID se expone como output | Se aplica por defecto a las subredes sin asociación explícita, como las subredes de base de datos. El módulo no agrega una ruta de Internet a esta tabla. |
| Tabla `aws_route_table.public` | Tabla adicional asociada a la VPC | Contiene la ruta por defecto para tráfico IPv4; está asociada explícitamente a las dos subredes públicas. |
| Tabla `aws_route_table.private` | Tabla adicional asociada a la VPC; etiqueta `Name = "aws-infrastructure-platform-private-dev-rt"` y tier `private` | Está asociada explícitamente a `private-a` y `private-b`. No tiene rutas declaradas aparte de la ruta local implícita de la VPC; no proporciona salida a Internet. |
| Tabla `aws_route_table.database` | Tabla adicional asociada a la VPC; etiqueta `Name = "aws-infrastructure-platform-database-dev-rt"` y tier `database` | Está creada sin rutas declaradas ni asociaciones a subredes. Por tanto, las subredes de base de datos no la utilizan y continúan usando la tabla principal de la VPC. |
| Ruta `aws_route.public_internet` | Destino `0.0.0.0/0`, gateway de destino `aws_internet_gateway.main` | Envía el tráfico IPv4 que no coincide con rutas más específicas al Internet Gateway. |
| Subredes públicas A y B | `10.0.1.0/24` en `us-east-2a`; `10.0.2.0/24` en `us-east-2b`; asignación automática de IP pública habilitada | Asociadas a la tabla pública, que enruta `0.0.0.0/0` al Internet Gateway. Segmentos previstos para recursos públicos, como balanceadores. |
| Subredes privadas A y B | `10.0.11.0/24` en `us-east-2a`; `10.0.12.0/24` en `us-east-2b`; asignación automática de IP pública deshabilitada | Segmentos previstos para cargas de aplicación. Ambas usan la tabla privada. No se declara NAT Gateway. |
| Subredes de base de datos A y B | `10.0.21.0/24` en `us-east-2a`; `10.0.22.0/24` en `us-east-2b`; asignación automática de IP pública deshabilitada | Segmentos previstos para datos. No están asociadas a la tabla de base de datos; usan la tabla principal de la VPC. No se declaran recursos de base de datos. |

Las subredes se crean con `cidrsubnet(var.vpc_cidr, 8, índice)`, por lo que sus rangos se derivan del CIDR configurable de la VPC. Los rangos de la tabla corresponden al valor predeterminado `10.0.0.0/16`.

## Flujo de tráfico

1. Los recursos dentro de la VPC se comunican mediante las rutas locales de la VPC.
2. Para que una subred tenga salida IPv4 a Internet a través del gateway, su tabla de rutas efectiva debe incluir `0.0.0.0/0` hacia el Internet Gateway.
3. La tabla `aws_route_table.public` incluye `0.0.0.0/0` hacia el Internet Gateway y está asociada a `public-a` y `public-b`. Esas subredes también habilitan la asignación automática de direcciones IPv4 públicas.
4. `private-a` y `private-b` están asociadas a `aws_route_table.private`, que no tiene rutas declaradas aparte de la ruta local implícita; por ello, no tienen ruta de salida a Internet. Aunque existe `aws_route_table.database`, no hay asociaciones declaradas para ella. Las subredes de base de datos usan la tabla principal de la VPC. No se declara NAT Gateway ni salida a Internet para estas subredes.
5. La asignación automática de IP pública no crea rutas; el acceso a Internet de las subredes públicas depende de la asociación con la tabla que enruta al Internet Gateway.

## Módulo y entorno

- `environments/dev` configura el proveedor AWS para `us-east-2` y el perfil CLI `aws-real` por defecto, y llama a `modules/networking` con `vpc_cidr`.
- El módulo de red exporta el ID de la VPC, su CIDR y el ID de la tabla de rutas principal. El entorno vuelve a exponer esos valores.
- El entorno también consulta la identidad de la cuenta, la región efectiva y las zonas de disponibilidad disponibles, y expone esas consultas como outputs.
- Las etiquetas comunes del entorno son `Project`, `Environment` y `ManagedBy`. Los recursos de red también definen etiquetas propias, incluyendo `Name` y `Tier`.
- El módulo valida que `vpc_cidr` sea un bloque CIDR IPv4 válido. Los valores del entorno se definen en `environments/dev/variables.tf`.
- Los valores predeterminados son región `us-east-2`, perfil `aws-real`, entorno `dev`, proyecto `aws-infraestructure-platform` y CIDR `10.0.0.0/16`.
- Las zonas de disponibilidad de las subredes están fijadas en el módulo a `us-east-2a` y `us-east-2b`; cambiar la región del proveedor requiere revisar esas zonas.

## Archivos de referencia

- [Entorno dev](../environments/dev/main.tf): composición del entorno.
- [Proveedor AWS](../environments/dev/providers.tf): versión de Terraform/proveedor, región y perfil.
- [Variables](../environments/dev/variables.tf): parámetros configurables del entorno.
- [Módulo de red](../modules/networking/main.tf): VPC, Internet Gateway y tablas de rutas pública, privada y de base de datos.
- [Subredes](../modules/networking/subnets.tf): rangos, zonas de disponibilidad y asociaciones de las subredes públicas y privadas a sus tablas de rutas.
- [Consideraciones de diseño](./design_considerations.txt): propósito previsto de las capas de subredes.
- [Mapa de subredes](./subnet_map.txt): resumen de CIDR y uso previsto.

## Validación antes del despliegue

Antes de aplicar cambios, ejecutar desde `environments/dev`:

```shell
terraform init
terraform validate
terraform plan
```

Las subredes públicas A y B están asociadas a la tabla pública y las subredes privadas A y B están asociadas a la tabla privada. La tabla de rutas de base de datos está creada, pero ninguna subred se asocia a ella; las subredes de base de datos usan la tabla principal de la VPC. Las tablas privada y de base de datos no tienen rutas de salida; cualquier salida mediante NAT requiere definir los recursos y rutas correspondientes, lo cual no forma parte de la configuración descrita aquí.
