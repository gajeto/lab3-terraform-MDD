# Laboratorio 3 - Terraform (MDD)
### Realizado por: Gustavo Jerez

## Estructura del repositorio

```
lab3-terraform-MDD/
├── eb-terraform-quickstart_homework/   # Ejercicios de afianzamiento
├── ec2-python-duckdb/                  # EC2 + Python + DuckDB 
├── ec2-python-pandas/                  # EC2 + Python + pandas
├── ec2-python-polars/                  # EC2 + Python + Polars
├── ec2-python-spark/                   # EC2 + Python + Spark
├── emr-cluster/                        # Cluster EMR 
├── .gitignore
└── README.md
```

## Subproyectos (resumen)

- **`eb-terraform-quickstart_homework/`**  
  Ejercicios de acercamiento a la sintaxis terraform y configuración de buckets e instancias EC2. Se incluye PDF con evidencias de aplicación.

- **`ec2-python-duckdb/` · `ec2-python-pandas/` · `ec2-python-polars/` · `ec2-python-spark/`**  
  Configuración en Terraform de **instancias EC2** con instalación de Python y librerías específicas desde `user_data`.

- **`emr-cluster/`**  
  Configuración en Terraform de un cluster **Amazon EMR** utilizando el módulo `emr` para habilitar la ejecución de jobs distribuidos.
---

**Convención por carpeta (subproyecto):**
- Archivos `.tf` especificos del módulo ec2 (`main.tf`, `variables.tf`, `outputs.tf`)
- Script `user_data.sh` para instalación de paquetes y ejecución de test de validación de instalación.
- Punto de entrada `main.tf` para aplicar configuración de Terraform.

---

## Cómo ejecutar un subproyecto

> Entrar a `ec2-python-pandas/` (o la carpeta deseada) y realizar los pasos indicados en el README.md de cada una:

Se asume que se cuenta con el agente SSM previamente instalado, asi como AWS CLI y Terraform. Se puede validar con los siguientes comandos:

```bash
terraform -version
aws sts get-caller-identity        
```

## Verificación rápida de instalación mediante SSM

Después de un `terraform apply` en un subproyecto, se puede iniciar la sesión SSM apuntando a la instancia requerida especificando el `--target` como el **instance_ID** que sale como output:

```bash
aws ssm start-session --target i-048d4c81938f15457
```

Luego cada subproyecto especifíca algunos comandos adicionales que pueden usarse para validación de la configuración.