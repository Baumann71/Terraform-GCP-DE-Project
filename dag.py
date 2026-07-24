from datetime import datetime, timedelta
from airflow.sdk import dag

from airflow.providers.google.cloud.operators.gcs import GCSListObjectsOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
import pendulum


default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries":1,
    "retry_delay": timedelta(minutes=5),
}

@dag(
    dag_id="gcs_to_bigquery_dag",
    default_args=default_args,
    description="A simple DAG to load data from GCS to BigQuery",
    start_date=pendulum.datetime(2026, 7, 23, tz="UTC"), #fecha desde que existe el DAG, a partir de esta fecha se ejecuta el DAG
    catchup=False, #si es True, ejecuta todas las instancias de DAG que no se han ejecutado desde la fecha de inicio
    schedule="0 13 * * *", #ejecutar a la 1pm cada dia
)
def gcs_to_bigquery_dag():
    
    list_gcs_files = GCSListObjectsOperator(
        task_id="list_gcs_files",
        bucket="bucket-ships-terraform-gcp-de-project",
        gcp_conn_id='google_cloud_default' #usa la SA de la VM mediante ADC
    )
    
    load_to_bigquery = GCSToBigQueryOperator(
        task_id = "load_to_bigquery",
        bucket = "bucket-ships-terraform-gcp-de-project",
        source_objects = list_gcs_files.output, #toma el resultado de la tarea ant (medainte XCom) y lo pasa como parametro a la tarea actual
        destination_project_dataset_table='terraform-gcp-de-project.dataset_ships.data_ships',
        source_format = 'CSV',
        create_disposition = 'CREATE_IF_NEEDED', #si la tabla no existe, la crea
        write_disposition = 'WRITE_TRUNCATE', #en cada carga reemplaza los datos existentes en la tabla
        autodetect=True, #detecta automáticamente el esquema de los datos
        gcp_conn_id='google_cloud_default',
    )
    
    list_gcs_files >> load_to_bigquery

dag_created = gcs_to_bigquery_dag() # airflow escanea cada arch .py en la carpeta dags/ y busca objetos tipo DAG ya instanciados, por eso hace falta
