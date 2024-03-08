resource "google_compute_network" "vpc_network" {
  name                    = "gke-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "gke-subnetwork"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.name
}

##### GKE CLUSTER #####

resource "google_container_cluster" "gke_cluster" {
  name     = "gke-cluster"
  location = var.region

  network    = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.subnet.name

  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = false
}

resource "google_container_node_pool" "node_pool" {
  name       = "my-node-pool"
  location   = var.region
  cluster    = google_container_cluster.gke_cluster.name
  node_count = var.gke_node_count

  node_config {
    preemptible  = true
    machine_type = var.gke_node_machine_type
    disk_size_gb = 30
  }

  autoscaling {
    min_node_count  = 0
    max_node_count  = var.gke_node_count * 2
    location_policy = "BALANCED"
  }
}

##### CLOUD SQL #####
resource "random_password" "db_password" {
  length           = 12
  special          = true
  override_special = "!#$%&*"
}
resource "google_sql_database_instance" "kubeflow_db" {
  name             = "kubeflow-database-instance"
  region           = "us-west1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = "false"
      private_network = google_compute_network.vpc_network.id
    }
  }

  deletion_protection = "false"
}

resource "google_sql_user" "users" {
  name     = "kubeflow"
  instance = google_sql_database_instance.kubeflow_db.name
  host     = "%"
  password = random_password.db_password.result
}

##### CLOUD STORAGE BUCKET #####
resource "random_string" "random" {
  length  = 10
  special = false
  upper   = false
}
resource "google_storage_bucket" "kubeflow_bucket" {
  name          = "kubeflow-bucket-${random_string.random.result}"
  location      = "US-WEST1"
  force_destroy = true
}