
variable "project_id" {
  description = "Id del proyecto de GCP donde se van a crear los recursos"
  type        = string
}

variable "region" {
  description = "Region de GCP para deployar los recursos"
  type        = string
  default     = "southamerica-east1" #sao pablo papi
}

variable "zone" {
    description="La zona de GCP donde alojar ciertos recursos, x ej la VM"
    type= string
    default = "southamerica-east1-a" #sao pablo papi
}

variable "bucket_name" {
  description = "Nombre del bucket de GCS que se va a crear"
  type        = string
  default     = "bucket-ships"
}

variable "dataset_id" {
  description = "Id del dataset de BigQuery que se va a crear"
  type        = string
  default     = "dataset_ships"
}

variable "table_ships" {
  description = "Id de la tabla de BigQuery que se va a crear"
  type        = string
  default     = "data_ships"
}

variable "table_schema"{
    description = "Schema de la tabla de BigQuery que se va a crear"
    type        = string
    default = <<EOF
    [
    {
        "name": "MMSI",
        "type": "INTEGER",
        "mode": "NULLABLE"
    },
    {
        "name": "BaseDateTime",
        "type": "TIMESTAMP",
        "mode": "NULLABLE"
    },
    {
        "name": "LAT",
        "type": "FLOAT",
        "mode": "NULLABLE"
    },
    {
        "name": "LON",
        "type": "FLOAT",
        "mode": "NULLABLE"
    },
    {
        "name": "SOG",
        "type": "FLOAT",
        "mode": "NULLABLE"
    },
    {
        "name": "COG",
        "type": "FLOAT",
        "mode": "NULLABLE"
    },
    {
        "name": "Heading",
        "type": "FLOAT",
        "mode": "NULLABLE"
    },
    {
        "name": "VesselName",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "IMO",
        "type": "INTEGER",
        "mode": "NULLABLE"
    },
    {
        "name": "CallSign",
        "type": "INTEGER",
        "mode": "NULLABLE"
    },
    {
        "name": "VesselType",
        "type": "INTEGER",
        "mode": "NULLABLE"
    },
    {
        "name": "Status",
        "type": "INTEGER",
        "mode": "NULLABLE"
    },
    {
        "name": "Length",
        "type": "INTEGER",
        "mode": "NULLABLE"
    },
    {
        "name": "Width",
        "type": "INTEGER",
        "mode": "NULLABLE"
    },
    {
        "name": "Draft",
        "type": "FLOAT",
        "mode": "NULLABLE"
    },
    {
        "name": "Cargo",
        "type": "INTEGER",
        "mode": "NULLABLE"
    },
    {
        "name": "TransceiverClass",
        "type": "STRING",
        "mode": "NULLABLE"
    }
    ]
    EOF
}

variable "external_ip_name" {
  description = "Nombre de la ip externa que se va a crear"
  type        = string
  default     = "external-ip-vm"
}

variable "instance_name" {
  description = "Nombre de la VM que se va a crear"
  type        = string
  default     = "airflow-vm"
}

variable "machine_type" {
  description = "Tipo de maquina de la VM que se va a crear"
  type        = string
  default     = "e2-medium" #2 vCPU, 4 GB RAM -> $0.06 USD x hora
}

variable "image_name" {
  description = "Imagen de la VM que se va a crear"
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "subnetwork_name" {
  description = "Nombre de la subred donde se va a crear la VM"
  type        = string
  default     = "default" 
}

variable "airflow_firewall_name" {
  default = "allow-airflow-8080"
}

variable "mi_ip" {
    description = "Mi ip jeje"
    type= string
}