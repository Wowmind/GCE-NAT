//create a VPC 
resource "google_compute_network" "network" {
  name                        = "mnetwork"
  auto_create_subnetworks     = "false"
}

//create a subnet
resource "google_compute_subnetwork" "my-custom-subnet" {
  name                        = "hibebe-subnet"
  ip_cidr_range               = "192.168.1.0/24"
  network                     = google_compute_network.network.self_link
  region                      = var.region
}

// create a VM
resource "google_compute_instance" "default" {
  project                     = var.project
  zone                        = "us-east1-b"
  name                        = "villakon-vm"
  machine_type                = "e2-medium"
  

  boot_disk {
    initialize_params {
      image                   = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network                  = "mnetwork"
    subnetwork               = google_compute_subnetwork.my-custom-subnet.self_link
    
  }
}

//create a firewall rule to allow SSH connection
resource "google_compute_firewall" "My_custom_network" {
  project                  = var.project
  name                     = "allow-ssh"
  network                  = google_compute_network.network.self_link

  allow {
    protocol               = "tcp"
    ports                  = ["22"]
  }
  source_ranges            = ["35.235.240.0/20"]
}   


//create IAP SSH permissions for your instance
resource "google_project_iam_member" "iap-project" {
    project               = var.project
    role                  = "roles/iap.tunnelResourceAccessor"
    member                = "serviceAccount:gke-guy@root-beanbag-392019.iam.gserviceaccount.com"
}


//crate Cloud Router

resource "google_compute_router" "compute_router" {
  project                = var.project
  name                   = "nat-router"
  network                = google_compute_network.network.self_link
  region                 = "us-east1"
}


module "cloud-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 4.0"
  project_id                         = var.project
  region                             = "us-east1"
  router                             = google_compute_router.compute_router.name
  name                               = "nat-config"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
