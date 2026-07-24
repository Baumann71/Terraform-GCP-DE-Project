#aca creamos la SA para la VM que corre airflow, y le damos permiso a la misma SA attacheada
# a la VM para que pueda cumplir las tasks del DAG 

#crea una SA, gcp genera lo que es el email de la SA que lo usamos luego para declarar el member en los permisos
resource "google_service_account" "airflow_sa" {
    account_id   = "airflow-vm-sa"
    display_name = "Service Account para la VM que corre Airflow"
}

#recordemos que la VM tiene que poder acceder al bucket y tambien dataset/tablas de BQ

#el iam member agg un permiso a un member sin quitarle los permisos que ya tenia
resource "google_project_iam_member" "airflow_sa_storage"{
    project = var.project_id
    role    = "roles/storage.objectAdmin" #permiso para leer y escribir en el bucket
    member  = "serviceAccount:${google_service_account.airflow_sa.email}"
}

resource "google_project_iam_member" "airflow_sa_bq_editor"{
    project = var.project_id
    role    = "roles/bigquery.dataEditor" #permiso para leer y escribir en dataset y tablas de BQ
    member  = "serviceAccount:${google_service_account.airflow_sa.email}"
}

resource "google_project_iam_member" "airflow_sa_bq_job_user"{
    project = var.project_id
    role    = "roles/bigquery.jobUser" #permiso para ejecutar jobs de BQ (queries)
    member  = "serviceAccount:${google_service_account.airflow_sa.email}"
}