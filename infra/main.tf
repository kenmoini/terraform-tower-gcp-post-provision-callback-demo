provider "google" {
  project = "rh-sat-demo"
  region  = "us-central1"
  zone    = "us-central1-c"
}
variable "host_config_key" {
  default = "1bc43655-2f11-4dd9-a8e1-2d72a56e4140"
  type    = string
}
variable "tower_endpoint" {
  default = "https://twr.example.com:443/api/v2/job_templates/11/callback/"
  type    = string
}
variable "tower_server" {
  default = "https://twr.example.com"
  type    = string
}
variable "tower_job_id" {
  default = 11
  type    = number
}
variable "tower_inventory_id" {
  type    = string
  default = "123"
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
  #metadata_startup_script = format("useradd kemo && mkdir -p /home/kemo/.ssh && usermod -aG sudo kemo && echo \"%s\" > /home/kemo/.ssh/authorized_keys && curl --data \"host_config_key=%s\" %s -k", file("~/.ssh/id_rsa.pub"), var.host_config_key, var.tower_endpoint)
  metadata_startup_script = format("useradd kemo && mkdir -p /home/kemo/.ssh && usermod -aG sudo kemo && echo \"%s\" > /home/kemo/.ssh/authorized_keys && curl -sSL -O /opt/request_tower_configuration.sh https://raw.githubusercontent.com/kenmoini/terraform-tower-gcp-post-provision-callback-demo/main/request_tower_configuration.sh && chmod +x /opt/request_tower_configuration.sh && /opt/request_tower_configuration.sh -k -c %s -s %s -t %d -i %d", file("~/.ssh/id_rsa.pub"), var.host_config_key, var.tower_server, var.tower_job_id, var.tower_inventory_id)

}