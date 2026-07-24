
output "airflow_ip" {
  description = "IP publica para acceder a la interfaz de Airflow"
  value       = google_compute_address.external_ip.address
}