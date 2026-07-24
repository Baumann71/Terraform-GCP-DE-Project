
terraform{
    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "~> 7.0" #version del provider
        }
    }
}

provider "google" {
    project = var.project_id
    region  = var.region
    credentials = file("secrets/sa-key.json") #una SA para terraform 
}
#por default cada resource hereda el project del bloque provider


# creamos el bucket de GCS
resource "google_storage_bucket" "bucket1" {
    name = "${var.bucket_name}-${var.project_id}"
    location = var.region
    storage_class = "STANDARD"
    
    force_destroy = true #permite borrar el bucket aunque tenga objetos dentro (testing)
    uniform_bucket_level_access = true

    soft_delete_policy {
      retention_duration_seconds=0 #no retiene objetos (o bucket) eliminados
    }
}

# creamos un dataset de BigQuery
resource "google_bigquery_dataset" "dataset1" {
    dataset_id = var.dataset_id
    location = var.region

    delete_contents_on_destroy = true #permite borrar el dataset aunque tenga tablas dentro (testing)
}

# creamos la tabla de las ship data
resource "google_bigquery_table" "ships"{
    #hereda location del dataset
    dataset_id = google_bigquery_dataset.dataset1.dataset_id
    table_id = var.table_ships
    schema = var.table_schema

    deletion_protection = false #x default es true, no permite borrar la tabla aunque tenga datos, 
                #le pongo false para q el terrafomr destroy la destruya (testing)

}


# creamos una ip externa fija para la VM (asi cuando se reinicie no cambia de IP externa)
#tras hacer el apply gcp da una IP real y esta se guarda en el terraform.tfstate 
resource "google_compute_address" "external_ip"{
    name = var.external_ip_name
    address_type = "EXTERNAL" #ip externa fija
    network_tier = "STANDARD" #la opcion x def es premium (una red de baja latencia que gcp tiene para sus clientes premium pero mas cara)

}


#creamos la VM que va a correr Airflow
resource "google_compute_instance" "airflow_vm" {
    name         = var.instance_name
    machine_type = var.machine_type
    zone = var.zone

    boot_disk {
        initialize_params {
            image = var.image_name
        }
    }

    #la VM necesita conectarse a una subred para obtener su IP interna
    #luego en la subred usamos la default que ofrece gcp
    network_interface {
            #projects/mi-proyecto-123/regions/us-central1/subnetworks/default
        subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/${var.subnetwork_name}"
        subnetwork_project = var.project_id #subred donde pertenece la subred, en este caso es redundante ya que es el mismo proyecto
        access_config { 
          #aka le damos la ip externa fija que definimos previamente a esta VM, sin esto la VM no tendria IP externa y no se podria acceder a ella desde internet
          nat_ip = google_compute_address.external_ip.address
          network_tier = "STANDARD" #coindice con la ip externa fija que definimos previamente
        }
    }

    service_account { 
        email = google_service_account.airflow_sa.email 
        scopes = ["cloud-platform"] #el scope cloud-platform le da acceso a todos los servicios/APIs de gcp, si queremos podemos poner scopes mas restrictivos
    }

}

#creamos la regla de firewall para permitir el trafico al puerto que usamos para acceder a Airflow (convencionalmente 8080)
#la refla de firewall se aplica a la VPC especifica, no a la VM, por eso no le pasamos el nombre de la VM
resource "google_compute_firewall" "airflow_firewall" {
    name    = var.airflow_firewall_name
    network = "projects/${var.project_id}/global/networks/default" #la default que ofrece gcp

    allow {
        protocol = "tcp"
        ports    = ["8080"]
    }

    source_ranges = ["${var.mi_ip}/32"] #aca deberiamos poner la nuestra para que nadie mas pueda acceder
        # el /32 significa "exactamente esta IP, ninguna otra"

}
