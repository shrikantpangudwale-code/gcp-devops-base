locals{
  service_account = "devops"
  vnet            = "devops-network"
  subnet          = "devops-subnetwork"
  firewall        = "devops-firewall"
  vm_instance     = "devops-vm"
}

# resource used to create the service account
resource "google_service_account" "service_account_user" {
  account_id   = local.service_account
  display_name = local.service_account
}

resource "google_project_iam_member" "member-role" {
for_each = toset([
		"roles/dns.admin",
    "roles/storage.admin",
    "roles/compute.admin",
		#"roles/appengine.admin",
    "roles/cloudbuild.builds.editor",
    "roles/iam.serviceAccountUser"
	])
	role = each.key
	member = "serviceAccount:${google_service_account.service_account_user.email}"
 	project = var.project
  depends_on = [google_project_service.project]
}

# resource to enable APIs
resource "google_project_service" "project" {
  project = var.project
  service = "appengine.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = true
}

# resource to create the network
resource "google_compute_network" "custom-network" {
  name                    = local.vnet
  auto_create_subnetworks = false
  mtu                     = 1460
}

# resource to create the sub-network
resource "google_compute_subnetwork" "network-with-ip-ranges" {
  name          = local.subnet
  ip_cidr_range = "10.68.0.0/28"
  region        = var.region
  network       = google_compute_network.custom-network.id
 }

# resource to create the firewall
resource "google_compute_firewall" "custom-firewall" {
  name    = local.firewall
  network = google_compute_network.custom-network.name
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["22","80", "8080", "3000"]
  }

   allow {
     protocol = "icmp"
   }
  
  target_tags =["devops-vm"]
}

resource "google_compute_instance" "devops-vm" {
  name                      = local.vm_instance
  zone                      = var.zone
  machine_type              = "n2-custom-2-4096"
  tags                      = ["devops-vm"]
  allow_stopping_for_update = true

  network_interface {
   network    = google_compute_network.custom-network.name
   subnetwork = google_compute_subnetwork.network-with-ip-ranges.name
   access_config {}
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size = 50
    }
    auto_delete = true
  }

  metadata = {
    startup-script  = file("../02-main.sh")
    enable-oslogin  = true
    github-base-url = var.github_base_url
    github-user     = var.github_user
    github-password = var.github_cred
    api_token       = var.api_token
    email_id        = var.email_id
  }

  service_account {
    email  = google_service_account.service_account_user.email
    scopes = [ "cloud-platform" ]
  }
 }
 