provider "google" {
  project = "rh-sat-demo"
  region  = "us-central1"
  zone    = "us-central1-c"
}
variable "host_config_key" {
  default = "123"
  type = string
}
variable "tower_endpoint" {
  default = "123"
  type = string
}
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
  metadata_startup_script = format("useradd kemo && mkdir -p /home/kemo/.ssh && usermod -aG sudo kemo && echo \"%s\" > /home/kemo/.ssh/authorized_keys && curl --data \"host_config_key=%s\" %s -k",file("~/.ssh/id_rsa.pub"), var.host_config_key, var.tower_endpoint)

}