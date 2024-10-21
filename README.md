GitHub Workflows
En esta sección se configuran los workflows que se ejecutan automáticamente cuando se realiza un commit en el repositorio, especialmente en la rama main.

Despliegue automático: Al hacer push en la rama main, se desplegará la infraestructura completa utilizando los archivos de configuración de Terraform (ubicados en main.tf y otros paths).

Permisos: Los permisos de acceso a los secretos y configuraciones de Terraform están gestionados mediante permissions, asegurando que el repositorio pueda acceder a los recursos necesarios.

Manejo de secretos: Las variables críticas, como credenciales y claves de acceso, se almacenan de forma segura utilizando GitHub Secrets. Esto permite acceder a las variables a través de secrets.<nombre_de_variable> sin exponerlas directamente en el código.

Tareas automatizadas: Dentro de la sección jobs, se definen las acciones que se ejecutan al hacer push. Entre ellas:

Generación y configuración de claves.
Inicialización de Terraform (terraform init).
Formateo y validación del código (terraform fmt).
Planificación del despliegue (terraform plan).
Aplicación de cambios (terraform apply).
Todo este proceso se realiza automáticamente sin necesidad de interacción manual en la terminal.

Entorno de Desarrollo (env)
El entorno de desarrollo (dev) está configurado para gestionar los recursos de la aplicación y el despliegue usando Docker y Terraform.

Docker Compose: El archivo docker-compose.yml incluye:

MonoMap API: La imagen de MonoMap utilizada en el examen anterior.
Let's Encrypt: Para gestionar el certificado SSL y la encriptación de la comunicación.
MongoDB: La base de datos utilizada por la aplicación.
Referencias en Terraform:

El archivo principal de Terraform (main.tf) hace referencia a diferentes módulos, organizando los recursos y variables de forma modular.
Las variables sensibles se toman de GitHub Secrets, lo que asegura que los recursos no estén expuestos y que las configuraciones estén adecuadamente categorizadas.
Proveedores y backend:

El proveedor principal configurado es Azure, y se utiliza un storage account previamente creado para almacenar el estado de Terraform (tfstate), lo que permite mantener la infraestructura de manera segura y consistente.
Módulos (modules)
Dentro de la carpeta modules, se encuentran los archivos principales para gestionar los recursos de la aplicación.

Gestión de recursos: El archivo main.tf dentro de los módulos define los recursos necesarios para la infraestructura.

Variables: Se definen variables reutilizables que se utilizan en los diferentes recursos, permitiendo una configuración más flexible y organizada.