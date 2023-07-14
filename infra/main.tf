resource "google_compute_network" "vpc_network" {
  name = "default-tf-network"
}

resource "google_compute_firewall" "tf_firewall" {
  name    = "tf-firewall"
  network = google_compute_network.vpc_network.name

  depends_on = [google_compute_network.vpc_network]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "9090"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "vm_instance" {
  depends_on = [google_compute_firewall.tf_firewall]

  name         = "terraform-rhel-instance"
  machine_type = "e2-standard-2"

  boot_disk {
    initialize_params {
      image = "rhel-8-v20210122"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default-tf-network"
    access_config {
    }
  }
  metadata_startup_script = format("useradd nuser && mkdir -p /home/nuser/.ssh && usermod -aG wheel nuser && echo \"nuser ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers && echo \"%s\" > /home/nuser/.ssh/authorized_keys && chown -R nuser:nuser /home/nuser && curl -sSL https://raw.githubusercontent.com/kenmoini/terraform-tower-gcp-post-provision-callback-demo/main/request_tower_configuration.sh > /opt/request_tower_configuration.sh && chmod +x /opt/request_tower_configuration.sh && /opt/request_tower_configuration.sh -k -c %s -s %s -t %d", file("~/.ssh/id_rsa.pub"), var.host_config_key, var.tower_server, var.tower_job_id)

}