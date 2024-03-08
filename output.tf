output "gcsCloudSqlInstanceName" {
  value = google_sql_database_instance.kubeflow_db.connection_name
}

output "gcsCloudSqlRootPassword" {
  value     = google_sql_database_instance.kubeflow_db.root_password
  sensitive = true
}

output "bucketName" {
  value = google_storage_bucket.kubeflow_bucket.name
}