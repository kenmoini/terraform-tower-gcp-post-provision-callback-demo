provider "google" {
  project = "rh-sat-demo"
  region  = "us-central1"
  zone    = "us-central1-c"
}
variable "host_config_key" {
  default = "1234567-4ef1-41a8-9454-2c57564e0f76"
  type    = string
}
variable "tower_server" {
  default = "https://twr.example.com"
  type    = string
}
variable "tower_job_id" {
  default = 123
  type    = number
}
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-rhel-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "rhel-8-v20210122"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
  metadata_startup_script = format("useradd nuser && mkdir -p /home/nuser/.ssh && usermod -aG wheel nuser && echo \"nuser ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers && echo \"%s\" > /home/nuser/.ssh/authorized_keys && chown -R nuser:nuser /home/nuser && curl -sSL https://raw.githubusercontent.com/kenmoini/terraform-tower-gcp-post-provision-callback-demo/main/request_tower_configuration.sh > /opt/request_tower_configuration.sh && chmod +x /opt/request_tower_configuration.sh && /opt/request_tower_configuration.sh -k -c %s -s %s -t %d", file("~/.ssh/id_rsa.pub"), var.host_config_key, var.tower_server, var.tower_job_id)

}